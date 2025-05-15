import boto3
import os # operating system structure used to containerize the environment variable in script, pulled from the aws lambda object that was deployed

def main(event, context):
    s3 = boto3.client('s3')

    bucket = os.environ["BUCKET_NAME"]                                      # pulls from the env variable defined in lambda_unity_to_s3_url_issuer.tf
    key = event["queryStringParameters"]["key"]                             # the key will be the save data aka file name
    method = event["queryStringParameters"].get("method", "put_object")     # "put_object" aka Save is default, if you want to read instead use "get_object"

    url = s3.generate_presigned_url(
        ClientMethod=method,
        Params={"Bucket": bucket, "Key": key},
        ExpiresIn=900
    )

    return {
        "statusCode": 200,
        "body": url
    }
