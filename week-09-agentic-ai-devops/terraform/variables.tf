variable "region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "af-south-1"
}

variable "project_name" {
  description = "Unique project name used for resource naming"
  type        = string
  default     = "portfolio-site-aderinto-adedayo-7684"
}

variable "environment" {
  description = "Deployment environment (e.g. production, staging)"
  type        = string
  default     = "production"
}

variable "domain_name" {
  description = "Optional custom domain name for CloudFront (leave empty to use default CloudFront domain)"
  type        = string
  default     = ""
}
