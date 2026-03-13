---
name: CloudFront security patterns
description: Recurring CloudFront security gaps found during Terraform audits
type: reference
---

## Patterns to check on every CloudFront distribution audit

**TLS version:**
- When `cloudfront_default_certificate = true` is used, CloudFront defaults to `minimum_protocol_version = "TLSv1"` — this is obsolete (deprecated RFC 8996, vulnerable to POODLE/BEAST).
- Fix requires switching to a custom ACM certificate and setting `minimum_protocol_version = "TLSv1.2_2021"`.
- Check state file attribute `viewer_certificate[0].minimum_protocol_version` to confirm actual deployed value.

**Response headers policy:**
- Missing `response_headers_policy_id` in cache behavior is a HIGH finding — zero security headers shipped to browsers.
- Must configure: CSP, X-Frame-Options (DENY), HSTS (max-age 63072000, includeSubdomains, preload), X-Content-Type-Options, Referrer-Policy.
- Check state file `default_cache_behavior[0].response_headers_policy_id` — empty string means none attached.

**Access logging:**
- `logging_config: []` in state means no access logs. MEDIUM finding.

**Compression:**
- `compress: false` in state is a best-practice gap. Always flag.

**IPv6:**
- `is_ipv6_enabled: false` is a best-practice gap. Always flag.

**WAF:**
- `web_acl_id: ""` means no WAF. LOW finding for public sites.

**OAC vs OAI:**
- Verify `origin_access_control_id` is set (OAC) and `s3_origin_config` is empty (not OAI). OAI is legacy.
