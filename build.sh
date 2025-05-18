#!/bin/bash
set -e

COMPUTE_DIR="compute"
PACKAGE_DIR="$COMPUTE_DIR/package"

# 1. Extract and clean up wheels in package (if any new ones were added)
echo "Extracting and cleaning up wheels in $PACKAGE_DIR..."
cd "$PACKAGE_DIR"
for whl in *.whl; do
    [ -e "$whl" ] && unzip -q "$whl"
done
rm -f *.whl
cd ../..

# 2. Build dependencies.zip for Lambda Layer
echo "Zipping dependencies from $PACKAGE_DIR into $COMPUTE_DIR/dependencies.zip..."
cd "$PACKAGE_DIR"
zip -r ../dependencies.zip .
cd ../..

# 3. Build Lambda zips (code only, no dependencies)
echo "Zipping Lambda code..."
cd "$COMPUTE_DIR"
zip -j unity_s3_url_issuer.zip unity_s3_url_issuer.py
zip -j firebase_authorizer.zip Firebase_Authorizer.py
cd ..

echo "dependencies.zip and Lambda zips are in $COMPUTE_DIR/"

terraform validate
terraform plan -out=plan

echo "Ready to run -> terraform apply plan"
