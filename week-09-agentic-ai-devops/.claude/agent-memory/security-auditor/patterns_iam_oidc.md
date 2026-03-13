---
name: IAM and OIDC security patterns
description: Patterns for IAM least privilege and GitHub Actions OIDC trust policy scoping
type: reference
---

## OIDC trust policy scoping — CRITICAL pattern

GitHub Actions OIDC trust policies must be scoped to a specific repo AND branch/ref.

**Bad (too broad):**
```json
"token.actions.githubusercontent.com:sub": "repo:*"
```

**Bad (repo-scoped but allows all branches/events):**
```json
"token.actions.githubusercontent.com:sub": "repo:ORG/REPO:*"
```

**Correct (specific branch):**
```json
"token.actions.githubusercontent.com:sub": "repo:ORG/REPO:ref:refs/heads/main"
```

Use `StringLike` (not `StringEquals`) only when wildcards are intentional and understood.
Always include the `aud` condition: `"token.actions.githubusercontent.com:aud": "sts.amazonaws.com"`.

## IAM least privilege for S3+CloudFront CI/CD role

Minimum permissions for a GitHub Actions deploy role (S3 sync + CloudFront invalidation):
- `s3:PutObject`, `s3:DeleteObject`, `s3:ListBucket` — scoped to specific bucket ARN
- `cloudfront:CreateInvalidation` — scoped to specific distribution ARN

Never grant `s3:*` or `cloudfront:*` wildcards.

## Missing IaC for IAM — LOW/MEDIUM pattern

If architecture docs describe OIDC CI/CD but no `aws_iam_openid_connect_provider` or `aws_iam_role` resources exist in Terraform, the role was either created manually (drift risk) or does not exist.
Flag as a missing resource finding.
