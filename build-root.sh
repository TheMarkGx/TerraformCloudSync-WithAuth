#!/bin/bash
set -e

SKIP_PLAN=false
UPDATE_DEPS=false

#Help section
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
  echo "Usage: $0 [--update_deps] [noplan] [--help|-h]"
  echo ""
  echo "  --update_deps     Rebuild Python dependencies layer (only needed if any were added/changed, otherwise this saves time)"
  echo "  noplan            Skip running 'terraform plan' (just build zips and validate)"
  echo "  --help, -h        Show this help message and exit"
  echo ""
  echo "Examples:"
  echo "  $0                        # Python build and plan"
  echo "  $0 --update_deps          # Rebuild Lambda code zips, AND dependency layer via pip & docker file"
  echo "  $0 noplan                 # Build lambda pythons only, skip 'terraform plan'"
  echo "  $0 --update_deps noplan   # Build everything but don't run plan"
  exit 0
fi

# Parse flags
for arg in "$@"; do
  if [ "$arg" = "noplan" ]; then
    SKIP_PLAN=true
  fi
  if [ "$arg" = "--update_deps" ]; then
    UPDATE_DEPS=true
  fi
done

#Load backend env vars if first-run script was ran
if [[ -f "./backend.env" ]]; then
  set -a; source "./backend.env"; set +a
fi


# Detect whether CI/CD backend is configured
REMOTE_MODE=false
if [[ -n "${TFSTATE_BUCKET:-}" && -n "${LOCK_TABLE:-}" && -n "${AWS_REGION:-}" ]]; then
  REMOTE_MODE=true
fi

if [[ "$REMOTE_MODE" == true ]]; then
  echo "==> Using REMOTE backend (S3 + DynamoDB)"
  terraform init -reconfigure \
    -backend-config="bucket=${TFSTATE_BUCKET}" \
    -backend-config="dynamodb_table=${LOCK_TABLE}" \
    -backend-config="region=${AWS_REGION}" \
    -backend-config="key=${TFSTATE_KEY:-${TF_WORKSPACE:-default}/terraform.tfstate}"
else
  echo "==> Using LOCAL backend ... -backend=false is set to main root."
"
  terraform init -reconfigure -backend=false
fi

COMPUTE_DIR="compute"
LAYER_BUILD_DIR="$COMPUTE_DIR/layer_build"

if [ "$UPDATE_DEPS" = true ]; then
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
  rm -f ../dependencies.zip
  zip -r ../dependencies.zip python
  cd - >/dev/null
else
  echo "Skipping dependency layer build."
fi

# 4. Build Lambda zips
cd "$COMPUTE_DIR"
rm -f unity_s3_url_issuer.zip firebase_authorizer.zip
zip -j unity_s3_url_issuer.zip unity_s3_url_issuer.py
zip -j firebase_authorizer.zip Firebase_Authorizer.py
cd - >/dev/null #need to go back to run terraform cmds

# 5. output summary
echo "Built in $COMPUTE_DIR:"
echo "  - dependencies.zip"
echo "  - unity_s3_url_issuer.zip"
echo "  - firebase_authorizer.zip"

terraform fmt -recursive
terraform validate

rm -rf "$LAYER_BUILD_DIR" #Make sure its cleaned

if [[ "$REMOTE_MODE" == true ]]; then
  echo
  echo "NOTE: Remote backend detected. Ready to run:"
  echo "  terraform -chdir=bootstrap apply"
  echo
fi

if [ "$SKIP_PLAN" = false ]; then
  terraform plan -out=plan
  echo "Ready to run 'terraform apply plan' (You can use -noplan to skip plan)"
else
  echo "Ready to run 'terraform apply'"
fi
  
