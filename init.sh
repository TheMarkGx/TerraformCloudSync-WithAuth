#!/bin/bash
set -e
# This script exists to workaround pip dependency on the machine running terraform

PYJWT_WHL="PyJWT-2.8.0-py3-none-any.whl"
CRYPT_WHL="cryptography-42.0.7-cp39-abi3-manylinux_2_28_x86_64.whl"
OUTPUT_ZIP="compute/dependencies.zip"

# Clean up build artifacts
rm -rf wheels package "$OUTPUT_ZIP"

mkdir -p wheels package

# Download wheels
echo "Downloading PyJWT and cryptography wheels..."
wget --user-agent="Mozilla/5.0" -L -o wheels/$PYJWT_WHL https://files.pythonhosted.org/packages/ae/63/08fd4c2b31c78b651db82bb178ac3f32e08c10e6a5c6f6e446e7be8b1a30/$PYJWT_WHL
wget --user-agent="Mozilla/5.0" -L -o wheels/$CRYPT_WHL https://files.pythonhosted.org/packages/f6/0c/b5bce35eab4a3eb9a91798284c95c2f7e313d0a19510bb3673bda6d860ad/$CRYPT_WHL


# Unzip wheels into package/
echo "Unzipping wheels..."
unzip -q wheels/$PYJWT_WHL -d package
unzip -q wheels/$CRYPT_WHL -d package

# Copy Python Lambda source files
echo "Copying Lambda source files from compute/..."
cp compute/*.py package/

# Create deployment ZIP in compute/
echo "Creating deployment zip at $OUTPUT_ZIP ..."
cd package
zip -r ../$OUTPUT_ZIP .
cd ..

echo "Done! Deployment package: $OUTPUT_ZIP"
