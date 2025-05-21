Phase 2 README
Overview
Phase 2 adds advanced account and user-data capabilities to the Unity cloud integration project, building on the secure, token-based infrastructure established in Phase 1.

Key Goals:
Per-user S3 save file/folder structure using Firebase UID.

Expanded OAuth (Google Sign-In) integration.

Additional endpoints for save slot/version management.

Admin/analytics endpoint for visualizing or downloading user data.

Hardened IAM policies for least-privilege and per-user data separation.

Architecture Overview
Unity Client:

Handles Google OAuth sign-in and sends Firebase ID token with every request.

Supports login, logout, and user status updates.

API Gateway (HTTP API):

Routes requests to backend Lambdas.

Authorizer validates ID tokens (Firebase).

Lambdas:

Handle uploads/downloads/deletes for user-specific S3 keys (folders).

New endpoints for versioning, save slot tagging, and (optional) admin/analytics.

S3 Buckets:

Stores per-user data in separate folders based on UID.

(Optional) Stores audit or analytics data for admin review.

Public Registry S3:

Hosts latest config.json for all environments.

New Endpoints/Functions
POST /upload — Save (per-user, with version/tag support)

GET /download — Load (by user and optionally by tag/version)

DELETE /delete — Remove a user's save file/slot

GET /admin/analytics — (Admin only) List or fetch user data for analytics

POST /save/tag — (Future) Tag or checkpoint a save file

Permissions/IAM Changes
S3 bucket policy and Lambda roles to allow:

Each user access only to their folder (by UID).

Admin endpoint to have read-only access to all users' data.

Outstanding “Known Issues” / Lessons from Phase 1
API Gateway HTTP API (v2) can have ghost/integration issues: Always verify authorizer is attached after deploy; redeploy the stage after any authorizer change.

S3 policy ordering: Always use depends_on to guarantee proper bucket/public policy application.

AWS propagation delays: Infrastructure changes can take several minutes to fully propagate.

Phase 2 TODOs
 Finalize save slot and version/tagging Lambda logic.

 Build Unity UI for selecting/checkpointing save slots.

 Implement analytics/admin endpoint (optional).

 Add automated tests for all new endpoints.

 Document new environment variables/infra requirements.