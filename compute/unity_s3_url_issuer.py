import boto3
import os
import json

s3 = boto3.client("s3")
bucket = os.environ["BUCKET_NAME"]
MAX_S3_VERSIONS = int(os.getenv("MAX_S3_VERSIONS", 10)) #Configurable, how many backup copies of an app state file will this deployment allow

### Supports minimal Exception logging to AWS Cloudwatch logs via print, later can change to import logging, and json dump into a logger object to log/trace the key that errored

def main(event, context):
    try:
        headers = event.get("headers", {})
        auth_header = headers.get("authorization") or headers.get("Authorization")

        if not auth_header or not auth_header.startswith("Bearer "):
            return error(401, "Missing or invalid token")

        token = auth_header[7:]

        # ---- Phase 1 Override dev-test-token: Accept it as a generic dev username, does NOT grant any special access----
        if token == "dev-test-token":
            user_id = "dev_user"
        else:
                    # Phase 2: insert JWT parsing and verification here
            return error(403, "Unauthorized")

        method = event["requestContext"]["http"]["method"]
        key = f"{user_id}/master-save.dat"

        if method == "POST": ### If any more routing paths are added in APIgateway*.tf, add the handlers as an elif
            return handle_upload(key)
        elif method == "GET":
            return handle_download(key)
        elif method == "DELETE":
            return handle_delete(key)
        else:
            return error(405, "Method not allowed")

    except Exception as e:
        return error(500, str(e))


def handle_upload(key):
    try: #with max versions enforced...
        versions = s3.list_object_versions(Bucket=bucket, Prefix=key).get("Versions", [])
        versions = sorted(versions, key=lambda v: v["LastModified"], reverse=True)

        if len(versions) > MAX_S3_VERSIONS:
            delete_keys = [{"Key": key, "VersionId": v["VersionId"]} for v in versions[MAX_S3_VERSIONS:]]
            s3.delete_objects(Bucket=bucket, Delete={"Objects": delete_keys})
    except Exception as e: 
            # Don't block upload URL just because cleanup failed, later can implement a regularly scheduled AWS based audit solution to correct these instances
        print(f"Version cleanup failed: {e}")

    url = s3.generate_presigned_url(
        ClientMethod="put_object",
        Params={"Bucket": bucket, "Key": key},
        ExpiresIn=900
    )
    return response(200, {"url": url}) #200 = success

def handle_download(key):
    try: # Check if object exists
        s3.head_object(Bucket=bucket, Key=key)
    except s3.exceptions.ClientError as e:
        if e.response["Error"]["Code"] == "404":
            return error(404, "Save file not found")
        else:
            raise

    url = s3.generate_presigned_url(
        ClientMethod="get_object",
        Params={"Bucket": bucket, "Key": key},
        ExpiresIn=900
    )

    return response(200, {"url": url})


def handle_delete(key):
    try:
        s3.delete_object(Bucket=bucket, Key=key)
    except s3.exceptions.NoSuchKey:
        return {
            "statusCode": 404,
            "body": json.dumps({"error": "Save file not found"})
        }

    return {
        "statusCode": 200,
        "body": json.dumps({"message": "File deleted"})
    }

def response(status_code, body=None):
    return {
        "statusCode": status_code,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body or {})
    }

def error(status_code, message):
    return response(status_code, {"error": message})

## Example json responses that include url's =
#  "url": "https://S3BUCKET.s3.amazonaws.com/USERNAME/SAVEFILE.dat?AWSAccessKeyId=xxxx...&Expires=1715809400&Signature=xyz..."

## Example json message =
#   "message": "File deleted"
