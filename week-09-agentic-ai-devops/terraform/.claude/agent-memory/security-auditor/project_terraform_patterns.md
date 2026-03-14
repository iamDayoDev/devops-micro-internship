---
name: terraform_security_patterns_portfolio
description: Security patterns and findings from the portfolio-site Terraform audit (March 2026). Records what was found, what was clean, and recurring issues to watch for in this codebase.
type: project
---

Audit performed 2026-03-13 against terraform/ directory (main.tf, variables.tf, outputs.tf, providers.tf, backend.tf, terraform.tfstate).

**Why:** First full security review of the infrastructure-as-code for the portfolio S3+CloudFront stack.
**How to apply:** Use this as a baseline for delta audits. Flag regressions against any item listed as PASS below.

## PASS (no action needed)
- S3 public access block: all four flags true (block_public_acls, block_public_policy, ignore_public_acls, restrict_public_buckets)
- CloudFront viewer_protocol_policy: "redirect-to-https" — HTTP redirected to HTTPS
- OAC (not OAI): aws_cloudfront_origin_access_control used with signing_behavior=always, signing_protocol=sigv4
- S3 bucket policy scoped to specific CloudFront distribution ARN via AWS:SourceArn condition
- S3 bucket policy action: only s3:GetObject (least privilege, no wildcard)
- KMS encryption configured in Terraform code (sse_algorithm = "aws:kms", bucket_key_enabled = true)
- No hardcoded credentials in .tf files

## FINDINGS (require remediation)

### CRITICAL
- terraform.tfstate committed to repo — contains AWS account ID 456041708812, CloudFront distribution ID, S3 bucket ARNs. Remote backend (backend.tf) is fully commented out.

### HIGH
- TLS minimum protocol version: TLSv1 in live state (tfstate line 204). Terraform code uses cloudfront_default_certificate=true which defaults to TLSv1. Should be TLSv1.2_2021 minimum.
- S3 versioning disabled — no recovery path if objects are overwritten or deleted.
- CloudFront access logging not configured (logging_config: [] in state).
- S3 access logging not configured (logging: [] in state).

### MEDIUM
- No CloudFront response headers policy — missing security headers (Content-Security-Policy, X-Frame-Options, Strict-Transport-Security, X-Content-Type-Options).
- compress = false on default_cache_behavior in live state (not set in Terraform code, defaults to false). Should be true.
- IPv6 disabled on CloudFront (is_ipv6_enabled: false in state) — not a security issue but a completeness gap.
- Backend S3 remote state is commented out — state stored locally, not encrypted at rest in S3 with encrypt=true.

### LOW
- No provider version pinning for patch level — "~> 5.0" allows any 5.x minor version. Should pin to ~> 5.x.y or use a lock file committed to repo.
- Terraform version constraint ">= 1.5" is too broad — should be pinned to a specific minor series (e.g., "~> 1.5").
- S3 encryption in live state shows AES256, not aws:kms — drift between Terraform code and actual deployed state.
- variables.tf exposes project name with full personal identifier as default value (not a secret but a privacy consideration).
