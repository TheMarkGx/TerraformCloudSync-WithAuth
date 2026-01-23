# CI/CD Bootstrap & Configuration

This repository uses GitHub Actions for CI/CD and Terraform for infrastructure
management. Required configuration values are supplied through **GitHub repo
variables** (for CI runs) and **local Terraform variable files** (for local runs).

To keep these values consistent and avoid manual setup, a single script is used
as the **authoritative configuration entry point**.

---

## Overview

**Authoritative configuration flow:**

```
first-run-cicd-setup.sh
   ├─ prompts for required values
   ├─ writes cicd-bootstrap/terraform.tfvars   (local Terraform)
   ├─ creates GitHub repo variables via gh     (CI / Actions)
   └─ keeps local + CI values in sync
```

Terraform itself does **not** create GitHub variables.
GitHub repo variables are created via the GitHub CLI (`gh`).

---

## Prerequisites

### Local tooling (WSL / Linux)

- Terraform
- Git
- GitHub CLI (`gh`)

Install GitHub CLI (Ubuntu / WSL):

```bash
sudo apt update
sudo apt install gh -y
```

Authenticate once:

```bash
gh auth login
```

Authentication tokens are stored locally by `gh` and can be revoked or replaced
at any time.

---

## First-Time CI/CD Setup (Authoritative)

From the **repository root**:

```bash
./first-run-cicd-setup.sh
```

The script will:

1. Prompt for required configuration values (e.g. AWS region)
2. Identify the target GitHub repository
3. Write `cicd-bootstrap/terraform.tfvars` for local Terraform runs
4. Create / update required GitHub repo variables using `gh`

This script is **safe to re-run** at any time.  
Re-running it will overwrite values to reassert the desired configuration.

> Do not manually edit GitHub repo variables or `terraform.tfvars`.
> Re-run the script instead.

---

## Applying the CI/CD Bootstrap

After configuration is complete:

```bash
terraform -chdir=cicd-bootstrap init
terraform -chdir=cicd-bootstrap apply
```

This initializes and applies the CI/CD bootstrap Terraform stack.

---

## Execution Contexts

### GitHub Actions (CI)

- GitHub repo variables are injected automatically
- Available in workflows as:
  - `${{ vars.VARIABLE_NAME }}`
- Terraform consumes values passed from the workflow environment

No local files are required in CI.

---

### Local Execution (WSL)

- GitHub repo variables are **not** available locally
- Terraform reads values from:
  - `cicd-bootstrap/terraform.tfvars`
  - or environment variables

This enables local `terraform plan` / `apply` for debugging and iteration.

---

## Variable Synchronization Strategy

- `first-run-cicd-setup.sh` is the **single source of truth**
- It ensures:
  - GitHub repo variables (CI)
  - Local Terraform variables
- stay in sync by construction

If values drift:
- re-run the script
- do not edit values manually

---

## Security Notes

- GitHub authentication tokens are managed by `gh`
- Tokens are:
  - scoped to selected repositories
  - revocable
  - replaceable if the environment is lost
- No tokens are committed to the repository

---

## When to Re-Run the Script

Re-run `first-run-cicd-setup.sh` if:

- You clone the repo to a new machine
- You add new required CI/CD variables
- You create a new environment (dev / prod)
- You want to reassert configuration consistency

---

## Design Rationale

This approach was chosen to:

- Avoid managing GitHub configuration in Terraform state
- Keep CI/CD bootstrap simple and explicit
- Allow fast local iteration and debugging
- Provide a clear, auditable setup path for new environments

---

## Summary

- **One script** controls configuration
- **GitHub CLI** manages repo variables
- **Terraform** consumes values, not secrets
- **CI and local runs** stay aligned without duplication

This setup is intentional, minimal, and re-runnable.
