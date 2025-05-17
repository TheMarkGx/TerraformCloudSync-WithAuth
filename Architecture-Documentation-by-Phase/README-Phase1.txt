# Phase 1 – Cloud Save Backend (Terraform + Unity Integration)

## Overview

This Terraform-managed project sets up a basic cloud backend for handling application state files (e.g. game saves) using AWS services. The infrastructure is designed for use with a Unity 6 client but is compatible with any HTTP-capable frontend.

### Features

- Terraform-managed deployment (supports multi-workspace via `terraform.workspace`)
- S3 bucket for storing raw save files
- Lambda function that returns signed S3 URLs for upload and download
- API Gateway exposing HTTP POST/GET/DELETE endpoints
- IAM roles to enable secure Lambda → S3 access

### Limitations (Phase 1)

- **Mock Authentication Only**
  - All requests require a static token: `Bearer dev-test-token`
  - No real identity validation is performed
  - Folder scoping is hardcoded to `dev_user/`
  - Intended for single-user/local testing

### Architecture (Phase 1)

Unity 6 Client
↓
API Gateway (HTTP POST /upload, GET /download, DELETE /delete)
↓
Lambda (validates mock token, returns signed S3 URL)
↓
S3 (stores 'dev_user/master-save.dat')


### Supported Operations

- `POST /upload` – Uploads a file via signed URL
- `GET /download` – Downloads the most recent save file
- `DELETE /delete` – Deletes the current save file

All endpoints require the header:
    Authorization: Bearer dev-test-token

### Terraform Resources

- `aws_s3_bucket`
- `aws_lambda_function`
- `aws_apigatewayv2_api`
- `aws_iam_role`
- `aws_iam_policy`

---

## Next Steps (Phase 2)

- Integrate Google OAuth for real user identity
- Enforce per-user save isolation via dynamic S3 pathing
- Validate OAuth tokens server-side (expiration, signature, `sub` field)
- Lock down API Gateway and reject unauthenticated calls
