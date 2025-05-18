import base64
import boto3
import os
import json

s3 = boto3.client("s3")
bucket = os.environ["BUCKET_NAME"]
MAX_S3_VERSIONS = int(os.getenv("MAX_S3_VERSIONS", 10)) #Configurable, how many backup copies of an app state file will this deployment allow

### Supports minimal Exception logging to AWS Cloudwatch logs via print, later can change to import logging, and json dump into a logger object to log/trace the key that errored

def main(event, context):
    try:
        # Extract user ID from authorizer context
        user_id = event.get("requestContext", {}) \
                       .get("authorizer", {}) \
                       .get("principalId")
        if not user_id:
            return error(401, "Unauthorized: No user identity found")

        method = event["requestContext"]["http"]["method"]
        key = f"{user_id}/master-save.dat" # Here's where it tracks per user access

        if method == "POST":
            return handle_upload(event, key)
        elif method == "GET":
            return handle_download(key)
        elif method == "DELETE":
            return handle_delete(key)
        else:
            return error(405, "Method not allowed")

    except Exception as e:
        return error(500, str(e))


def handle_upload(event, key):
    try:
        # Get raw file content from request body
        body = event.get("body", "")
        if event.get("isBase64Encoded", False):
            body = base64.b64decode(body)
        else:
            body = body.encode("utf-8")

        # Apply version culling logic
        version_data = s3.list_object_versions(Bucket=bucket, Prefix=key)
        versions = version_data.get("Versions", []) or []        
        versions = [v for v in versions if "VersionId" in v] # Filter out delete markers, just in case
        versions = sorted(versions, key=lambda v: v["LastModified"], reverse=True)

        if len(versions) > MAX_S3_VERSIONS:
            delete_keys = [{"Key": key, "VersionId": v["VersionId"]} for v in versions[MAX_S3_VERSIONS:]]
            s3.delete_objects(Bucket=bucket, Delete={"Objects": delete_keys})


        # Upload the file
        s3.put_object(
            Bucket=bucket,
            Key=key,
            Body=body,
            ContentType="application/octet-stream"
        )

        return response(200, {"message": "Upload complete"})

    except Exception as e:
        print(f"Upload failed: {e}")
        return error(500, str(e)) #200 = success

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
        return response(200, {"message": f"Deleted {key} from {bucket}."})
    except s3.exceptions.NoSuchKey:
        return error(404, "Save file not found")
    except Exception as e:
        return error(500, f"Delete failed: {str(e)}")


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
