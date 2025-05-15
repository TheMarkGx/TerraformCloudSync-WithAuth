# Phase 1 – Cloud State File Handler/Core Backend Setup

## Overview

This project is a Terraform-managed deployment of a cloud backend system designed to handle application state files (such as game saves) in AWS.
The initial phase focuses on standing up core infrastructure components that allow for example a Unity 6 client to upload and download files by user-defined filename.

### Features

* Terraform with multi-workspace support (abstraction based on terraform.workspace name)
* S3 bucket for storing application state files
* API Gateway exposing HTTP endpoints
* Lambda function for handling file uploads/downloads via generating pre-signed URLs
* Matching IAM to support lambda talking to S3

### Limitations (Phase 1)

* **No authentication implemented**

  * All API calls are publicly accessible (even though only 1 exists so far)
  * No user isolation or folder scoping enforced. Just basic upload/download (Phase 1 represents a private, solo oriented service)


### Architecture (Phase 1)

```
Unity 6 Client
    ↓
API Gateway (HTTP POST/GET)
    ↓
Lambda Function (no auth)
    ↓
S3 Bucket (flat structure)
```

### Usage

Clients can perform the following operations:

* `POST /upload/{filename}` to upload a file
* `GET /download/{filename}` to retrieve a file

### Terraform Resources

* `aws_s3_bucket`
* `aws_lambda_function`
* `aws_apigatewayv2_api`
* `aws_iam_role`

---

## Next Steps (Phase 2)

* Integrate Google OAuth for user identity
* Enforce per-user folder scoping in S3
* Validate tokens in Lambda to extract user ID
* Update API Gateway/Lambda to reject unauthenticated access (mostly to cover expiration of OAuth)
