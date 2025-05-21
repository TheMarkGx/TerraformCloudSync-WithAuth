import json
import urllib.request
import jwt  # PyJWT library, must be included in your deployment package
from jwt.algorithms import RSAAlgorithm
from cryptography import x509
from cryptography.hazmat.backends import default_backend
# DOCS Verify ID Tokens - https://firebase.google.com/docs/auth/admin/verify-id-tokens#python
# Cache public keys from Firebase
FIREBASE_CERTS_URL = "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com"
_cached_certs = None

def get_firebase_certs():
    global _cached_certs
    if not _cached_certs:
        with urllib.request.urlopen(FIREBASE_CERTS_URL) as response:
            _cached_certs = json.loads(response.read())
    return _cached_certs

# AWS Lambda Authorizers must return an IAM policy document to API Gateway to allow or deny the incoming request.
# https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-use-lambda-authorizer.html#api-gateway-lambda-authorizer-proxy-format
def generate_policy(principal_id, effect, resource):
    return {
        'principalId': principal_id,
        'policyDocument': {
            'Version': '2012-10-17',
            'Statement': [{
                'Action': 'execute-api:Invoke',
                'Effect': effect,
                'Resource': resource
            }]
        }
    }
def main(event, context):
    print("\n====== LAMBDA INVOCATION ======")
    print("EVENT DUMP:", event)
    print("EVENT TYPE:", type(event))
    print("EVENT DIR():", dir(event))
    if not isinstance(event, dict):
        print("Event is not a dict. Returning DENY.")
        return generate_policy('unauthorized', 'Deny', '*')

    try:
        print("\n[1] Accessing event.get('authorizationToken')...")
        print("event type:", type(event))
        auth_header = event.get('authorizationToken')
        print("auth_header:", auth_header)

        print("\n[2] Accessing event.get('methodArn')...")
        method_arn = event.get('methodArn')
        print("method_arn:", method_arn)

        if not auth_header or not auth_header.startswith('Bearer '):
            print("No Bearer token found, returning DENY.")
            return generate_policy('unauthorized', 'Deny', method_arn or '*')

        token = auth_header.split(' ', 1)[1]
        print("Token extracted.")

        # Firebase Certs
        print("\n[3] Getting Firebase certs...")
        certs = get_firebase_certs()
        print("certs type:", type(certs))

        print("\n[4] Getting unverified JWT header...")
        unverified = jwt.get_unverified_header(token)
        print("unverified header:", unverified)

        kid = unverified.get('kid')
        print("kid:", kid)

        if kid not in certs:
            print("KID not found in certs, returning DENY.")
            return generate_policy('unauthorized', 'Deny', method_arn or '*')

        print("\n[5] Getting public key...")
        public_key_data = certs[kid]
        print("public_key_data type:", type(public_key_data))
        print("public_key_data preview:", str(public_key_data)[:60])
        cert = x509.load_pem_x509_certificate(public_key_data.encode('utf-8'), default_backend()) #convert from x509 cert
        public_key = cert.public_key() #get the key from the x509 cert
        #public_key = RSAAlgorithm.from_jwk(json.dumps(public_key_data) if isinstance(public_key_data, dict) else public_key_data)
        print("public_key created.")

        # Decode token
        print("\n[6] Decoding JWT...")
        decoded = jwt.decode(
            token,
            public_key,
            algorithms=['RS256'],
            audience='idler-6124e',  # Replace with your actual project ID!
            issuer='https://securetoken.google.com/idler-6124e'  # Replace with your actual project ID!
        )
        print("decoded JWT:", decoded)

        uid = decoded.get('user_id')
        print(f"Decoded UID: {uid}")

        # Allow invocation
        print("Returning ALLOW policy.")
        return generate_policy(uid, 'Allow', method_arn)

    except Exception as e:
        print("\nEXCEPTION CAUGHT IN TRY BLOCK!")
        print(f"Auth error: {repr(e)}")
        import traceback
        traceback.print_exc()
        return generate_policy('unauthorized', 'Deny', event.get('methodArn', '*') if isinstance(event, dict) else '*')
    
def main2(event, context):
    print("FIREBASE AUTHORIZER INVOKED: EVENT DUMP:", event, type(event))
    # Extract token from 'Authorization' header (expecting: "Bearer <token>")
    print("ABOUT TO ACCESS .get ON EVENT")
    print("event dir():", dir(event))
    print("event type:", type(event))
    try:
        auth_header = event.get('authorizationToken')
    except Exception as e:
        print("EXCEPTION IN get('authorizationToken'):", repr(e))
        raise
    
    if not isinstance(event, dict) or 'authorizationToken' not in event:
        # Only allow if this is a CORS preflight (OPTIONS)
        if event.get('httpMethod', '').upper() == 'OPTIONS':
            print("CORS preflight detected; allowing through.")
            return generate_policy('anonymous', 'Allow', event.get('methodArn', '*'))
        print("Non-auth/non-OPTIONS event, ignoring/denying.")
        return None
    
    auth_header = event.get('authorizationToken')
    method_arn = event.get('methodArn')
    try:
        if not auth_header or not auth_header.startswith('Bearer '):
            raise Exception("Unauthorized: No Bearer token found")
        token = auth_header.split(' ', 1)[1] # Just get the token

        certs = get_firebase_certs()

        # Decode header to get which public key id was used so we can match it to private later
        unverified = jwt.get_unverified_header(token)
        kid = unverified['kid']
        if kid not in certs:
            raise Exception("Unauthorized: Invalid kid") # Certs might've refreshed/gotten outdated by firebase
        public_key = RSAAlgorithm.from_jwk(json.dumps(certs[kid]))

        # If this deployment is being applied to any frontend it was not originally designed for,
        # REPLACE idler-6124e WITH PROJECT ID FROM FIREBASE CONSOLE - This is project specific
        # Later on implement this as a variable through terraform's root
        decoded = jwt.decode(
            token,
            public_key,
            algorithms=['RS256'],
            audience='idler-6124e',
            issuer='https://securetoken.google.com/idler-6124e'
        )
        uid = decoded['user_id']
        print(f"Decoded UID: {uid}")

        # Allow invocation
        return generate_policy(uid, 'Allow', method_arn)

    except Exception as e:
        print(f"Auth error: {e}")
        return generate_policy('unauthorized', 'Deny', method_arn)