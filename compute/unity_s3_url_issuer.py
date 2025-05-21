import base64
import boto3
import os
import json

s3 = boto3.client("s3")
bucket = os.environ["BUCKET_NAME"]
MAX_S3_VERSIONS = int(os.getenv("MAX_S3_VERSIONS", 10)) #Configurable, how many backup copies of an app state file will this deployment allow

### Supports minimal Exception logging to AWS Cloudwatch logs via print, later can change to import logging, and json dump into a logger object to log/trace the key that errored

def main(event, context):
    print("EVENT RECEIVED:", json.dumps(event))
    # For REST API, method is event['httpMethod']
    method = event.get('httpMethod')
    # Authorizer principalId in event['requestContext']['authorizer'], principle = user
    principal = event.get('requestContext', {}).get('authorizer', {}).get('principalId')
    if not principal:
        return error(401, 'Unauthorized: No user identity found')
    # Should also be a variable later to not constrict state files to this one name
    key = f"{principal}/master-save.dat"

    try:
        if method == 'POST':
            return handle_upload(event, key)
        elif method == 'GET':
            return handle_download(key)
        elif method == 'DELETE':
            return handle_delete(key)
        else:
            return error(405, 'Method not allowed')
    except Exception as ex:
        print(f"Handler exception: {ex}")
        return error(500, str(ex))


def handle_upload(event, key):
    body = event.get('body', '')
    if event.get('isBase64Encoded', False):
        payload = base64.b64decode(body) #raw file content
    else:
        payload = body.encode('utf-8')

        # Apply version count trimming
    try:
        versions = s3.list_object_versions(Bucket=bucket, Prefix=key).get('Versions', [])
        versions = [v for v in versions if 'VersionId' in v]
        versions.sort(key=lambda v: v['LastModified'], reverse=True)
        if len(versions) > MAX_S3_VERSIONS:
            old = versions[MAX_S3_VERSIONS:]
            s3.delete_objects(Bucket=bucket, Delete={'Objects': [{'Key': key, 'VersionId': v['VersionId']} for v in old]})
        # upload    
        s3.put_object(Bucket=bucket, Key=key, Body=payload, ContentType='application/octet-stream')
        return response(200, {'message': 'Upload complete'})
    except Exception as e:
        print(f"Upload failed: {e}")
        return error(500, str(e)) #200 = good

def handle_download(key):
    try:
        s3.head_object(Bucket=bucket, Key=key)
    except s3.exceptions.ClientError as e:
        if e.response['Error']['Code'] == '404':
            return error(404, 'Save file not found')
        raise
    url = s3.generate_presigned_url('get_object', Params={'Bucket': bucket, 'Key': key}, ExpiresIn=900)
    return response(200, {'url': url})


def handle_delete(key):
    try:
        s3.delete_object(Bucket=bucket, Key=key)
        return response(200, {'message': f'Deleted {key}'})
    except s3.exceptions.NoSuchKey:
        return error(404, 'Save file not found')
    except Exception as e:
        return error(500, str(e))


def response(code, body=None):
    return {'statusCode': code, 'headers': {'Content-Type': 'application/json'}, 'body': json.dumps(body or {})}

def error(code, msg):
    return response(code, {'error': msg})


## Example json responses that include url's =
#  "url": "https://S3BUCKET.s3.amazonaws.com/USERNAME/SAVEFILE.dat?AWSAccessKeyId=xxxx...&Expires=1715809400&Signature=xyz..."

## Example json message =
#   "message": "File deleted"
