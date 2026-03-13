---
name: Terraform state and backend security patterns
description: Patterns for detecting committed state files and disabled remote backends
type: reference
---

## State file in version control — CRITICAL pattern

Always check if `terraform.tfstate` or `terraform.tfstate.backup` are tracked in git.
- Use `git ls-files terraform/` to confirm tracking status.
- State files contain AWS account IDs, resource ARNs, and potentially plaintext secrets.
- Fix: add to .gitignore, run `git rm --cached`, activate remote backend.

## Commented-out backend block — HIGH pattern

A `backend.tf` where the entire `terraform { backend "s3" { ... } }` block is commented out means:
- Local state only — no remote locking (DynamoDB table useless).
- State file accumulates on developer machine, risk of loss or commit.
- Concurrent applies can corrupt state.

Fix: uncomment + `terraform init -migrate-state`.

## Hardcoded account IDs in backend config — HIGH pattern

Backend configs frequently contain hardcoded S3 bucket names that encode account IDs or project names.
- Check for AWS account ID patterns: `\d{12}` in any .tf file.
- These appear in `backend.tf` bucket names and in state file ARNs/conditions.
- Remove state from git to prevent account ID leakage via git history.
