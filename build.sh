#!/bin/bash
set -e

SKIP_PLAN=false
if [ "$1" = "noplan" ]; then
  SKIP_PLAN=true
fi

COMPUTE_DIR="compute"
LAYER_BUILD_DIR="$COMPUTE_DIR/layer_build"

# 1. Clean previous builds
echo "Cleaning old layer build..."
rm -rf "$LAYER_BUILD_DIR"
mkdir -p "$LAYER_BUILD_DIR/python"

# 2. Build dependencies in AWS Lambda Python 3.11 Docker image
echo "Building dependencies in AWS Lambda Python 3.11 Docker image..."
#add with user as owner
docker run --rm --entrypoint "" -u "$(id -u):$(id -g)" -v "$PWD/$LAYER_BUILD_DIR/python:/opt/python" public.ecr.aws/lambda/python:3.11 /var/lang/bin/python3.11 -m pip install cryptography PyJWT --target /opt/python

# 3. Zip the layer into dependencies.zip
# AWS Lambda Layer needs top-level 'python/' directory
echo "Zipping layer (with python/ wrapper) to compute/dependencies.zip..."
cd "$LAYER_BUILD_DIR"
zip -r ../dependencies.zip python
cd - >/dev/null

# 4. Build Lambda zips
cd "$COMPUTE_DIR"
zip -j unity_s3_url_issuer.zip unity_s3_url_issuer.py
zip -j firebase_authorizer.zip Firebase_Authorizer.py
cd - >/dev/null #need to go back to run terraform cmds

# 5. output summary
echo "Built in $COMPUTE_DIR:"
echo "  - dependencies.zip"
echo "  - unity_s3_url_issuer.zip"
echo "  - firebase_authorizer.zip"

terraform fmt
terraform validate

rm -rf "$LAYER_BUILD_DIR" #Make sure its cleaned

if [ "$SKIP_PLAN" = false ]; then
  terraform plan -out=plan
  echo "Ready to run 'terraform apply plan' (You can use -noplan to skip plan)"
else
  echo "Ready to run 'terraform apply'"
fi
  
