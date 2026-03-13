# Security Auditor — Agent Memory Index

## Project Findings

- [project_portfolio_site_audit.md](project_portfolio_site_audit.md) — Full findings from 2026-03-13 audit of portfolio-site Terraform (CRITICAL: state in git; HIGH: no TLS 1.2, no security headers, disabled backend)

## Pattern Libraries

- [patterns_cloudfront.md](patterns_cloudfront.md) — CloudFront security checks: TLS version, response headers policy, logging, compression, IPv6, WAF, OAC vs OAI
- [patterns_state_and_backend.md](patterns_state_and_backend.md) — State file in git (CRITICAL), commented-out backend (HIGH), hardcoded account IDs
- [patterns_iam_oidc.md](patterns_iam_oidc.md) — GitHub Actions OIDC trust policy scoping, IAM least privilege for S3+CloudFront deploy roles, missing IaC for IAM
