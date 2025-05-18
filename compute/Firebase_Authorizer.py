import json
import urllib.request
import jwt  # PyJWT library, must be included in your deployment package
from jwt.algorithms import RSAAlgorithm
# DOCS Verify ID Tokens - https://firebase.google.com/docs/auth/admin/verify-id-tokens#python
# Cache public keys from Firebase
FIREBASE_CERTS_URL = "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com"
_cached_certs = None

def get_firebase_certs():
    global _cached_certs
    if not _cached_certs:
        with urllib.request.urlopen(FIREBASE_CERTS_URL) as response:
            certs = response.read()
            _cached_certs = json.loads(certs)
    return _cached_certs

# AWS Lambda Authorizers must return an IAM policy document to API Gateway to allow or deny the incoming request.
# https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-use-lambda-authorizer.html#api-gateway-lambda-authorizer-proxy-format
def generate_policy(principal_id, effect, resource):
    return {
        "principalId": principal_id,
        "policyDocument": {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Action": "execute-api:Invoke",
                    "Effect": effect,
                    "Resource": resource
                }
            ]
        }
    }

def main(event, context):
    token = None
    try:
        # Extract token from 'Authorization' header (expecting: "Bearer <token>")
        auth_header = event['headers'].get('authorization') or event['headers'].get('Authorization')
        if not auth_header or not auth_header.startswith('Bearer '):
            raise Exception("Unauthorized: No Bearer token found")

        token = auth_header.split(' ')[1] # Just get the token

        certs = get_firebase_certs()

        # Decode header to get which public key id was used so we can match it to private later
        unverified_header = jwt.get_unverified_header(token)
        kid = unverified_header['kid']

        if kid not in certs:
            raise Exception("Unauthorized: Invalid kid") # Certs might've refreshed/gotten outdated by firebase

        public_key = RSAAlgorithm.from_jwk(json.dumps(certs[kid]))

        # If this deployment is being applied to any frontend it was not originally designed for,
        # REPLACE idler-6124e WITH PROJECT ID FROM FIREBASE CONSOLE - This is project specific
        decoded_token = jwt.decode(
            token,
            public_key,
            algorithms=['RS256'],
            audience='idler-6124e',
            issuer='https://securetoken.google.com/idler-6124e'
        )

        uid = decoded_token['user_id']

        # If verification passed, generate allow policy
        policy = generate_policy(uid, "Allow", event['routeArn'])
        return policy

    except Exception as e:
        print(f"Auth error: {str(e)}")
        policy = generate_policy("unauthorized", "Deny", event.get('routeArn', '*'))
        return policy
