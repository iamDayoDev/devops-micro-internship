---
name: portfolio-site security audit findings
description: Key security findings from the portfolio-site Terraform configuration — last updated 2026-03-13 (fourth full run)
type: project
---

Audit completed 2026-03-13 (fourth full run). All Terraform source files and terraform.tfstate cross-checked to verify actual deployed values vs declared config. State drift discovered on encryption (see Medium findings). NONE of the findings below have been remediated as of this run.

**Why:** Ongoing audit of a static portfolio site deployed to S3 + CloudFront via Terraform. No prior remediation has occurred.

**How to apply:** When asked about this project's infrastructure state, assume these findings exist unless the user confirms they have been remediated. Prioritize state file removal and remote backend activation before any other work.

---

## CRITICAL

- **terraform.tfstate committed to git** — exposes AWS account ID 456041708812, CloudFront distribution ID E2BUGDUEPRH4H2, S3 bucket ARN, and the full rendered IAM policy condition (SourceArn). Must be removed from git history and backend migrated to S3 remote state.

## HIGH

- **S3 remote backend commented out** — entire `terraform { backend "s3" { ... } }` block in backend.tf is commented out; Terraform is operating on local state only, no DynamoDB locking, race condition possible.
- **TLS minimum protocol version is TLSv1** — `viewer_certificate { cloudfront_default_certificate = true }` in main.tf forces CloudFront to default to TLSv1 (confirmed in state: `minimum_protocol_version = "TLSv1"`). TLSv1 and TLSv1.1 are deprecated (RFC 8996) and vulnerable to POODLE/BEAST. Requires ACM certificate + explicit `minimum_protocol_version = "TLSv1.2_2021"`.
- **No CloudFront response headers policy** — `response_headers_policy_id` is empty string in deployed state. Zero security headers delivered to browsers: no CSP, no HSTS, no X-Frame-Options, no X-Content-Type-Options, no Referrer-Policy.

## MEDIUM

- **Encryption state drift** — main.tf declares `sse_algorithm = "aws:kms"` with `bucket_key_enabled = true`, but the deployed state shows `sse_algorithm = "AES256"` and `bucket_key_enabled = false`. The bucket is NOT encrypted with KMS despite the Terraform declaration. Requires `terraform apply` to enforce, or investigation of why drift occurred.
- **S3 bucket versioning disabled** — `versioning.enabled = false` in state. An accidental `aws s3 sync --delete` will permanently destroy site content with no recovery path.
- **No CloudFront access logging** — `logging_config: []` in state. No audit trail for requests to the distribution.
- **CloudFront compression disabled** — `compress: false` in state. Not a security issue per se but means Brotli/gzip are not applied; also bypasses any Content-Encoding inspection in future WAF rules.
- **IPv6 disabled on CloudFront** — `is_ipv6_enabled: false`. Best practice gap; also limits ability to apply future IPv6-specific WAF rules.

## LOW

- **No WAF Web ACL on CloudFront** — `web_acl_id: ""` in state. No rate limiting, bot control, or managed rule groups protecting the distribution.
- **GitHub Actions OIDC/IAM role not in Terraform** — CLAUDE.md describes OIDC-based CI/CD but no `aws_iam_openid_connect_provider` or `aws_iam_role` resource exists in any .tf file. Role was either created manually (drift risk, not reproducible) or does not exist.
