---
name: portfolio-site security audit findings
description: Key security findings from the first full audit of the portfolio-site Terraform configuration (2026-03-13)
type: project
---

Audit completed 2026-03-13 on terraform/ directory (5 files: main.tf, variables.tf, providers.tf, backend.tf, outputs.tf + terraform.tfstate).

**Why:** Initial audit of a static portfolio site deployed to S3 + CloudFront via Terraform. No prior audit existed.

**Critical finding:**
- terraform.tfstate is committed to git — exposes AWS account ID 456041708812, CloudFront ID E2BUGDUEPRH4H2, S3 bucket ARN. Must be removed from git history and migrated to the S3 remote backend.

**High findings:**
- Remote S3 backend block in backend.tf is commented out — local state only, no locking.
- TLS minimum protocol version is TLSv1 (obsolete) due to using cloudfront_default_certificate without explicit minimum_protocol_version override.
- No CloudFront response headers policy — zero security headers (no CSP, HSTS, X-Frame-Options, X-Content-Type-Options).

**Medium findings:**
- S3 bucket versioning disabled — no recovery from accidental sync deletion.
- No CloudFront access logging.
- SSE-S3 used instead of SSE-KMS.
- IPv6 disabled on CloudFront.
- Compression disabled on CloudFront cache behavior.

**Low findings:**
- No WAF Web ACL on CloudFront.
- OIDC/IAM role for GitHub Actions CI/CD is not defined in Terraform (possible manual creation or missing entirely).

**How to apply:** When asked about this project's infrastructure state, assume these findings exist unless the user confirms they have been remediated. Prioritize state file removal and remote backend activation before any other work.
