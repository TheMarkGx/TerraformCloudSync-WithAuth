#!/bin/bash

set -e  # Exit on any error

LAMBDA_SRC="compute/unity_s3_url_issuer.py"
LAMBDA_ZIP="compute/unity_s3_url_issuer.zip"

echo "Cleaning up old Lambda zip (if any)..."
rm -f "$LAMBDA_ZIP"

echo "Zipping Lambda source..."
zip -j "$LAMBDA_ZIP" "$LAMBDA_SRC"

echo "Running Terraform validate..."
terraform validate

echo "Generating Terraform plan..."
terraform plan -out=PLAN

echo "ready to run -> terraform apply PLAN"
