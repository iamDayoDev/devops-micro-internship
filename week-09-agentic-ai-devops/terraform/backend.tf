# Remote state backend (S3 + DynamoDB)
#
# BOOTSTRAP INSTRUCTIONS:
#   The S3 bucket and DynamoDB table referenced here must exist before
#   Terraform can use this backend.  Follow these steps once:
#
#   1. Leave this block commented out and run:
#        terraform init
#        terraform apply
#      This creates the S3 bucket and all other resources with local state.
#
#   2. Uncomment the entire terraform { backend "s3" { ... } } block below.
#
#   3. Migrate the local state to the remote backend:
#        terraform init -migrate-state
#      Confirm the migration prompt with "yes".
#
#   After migration all subsequent plans/applies will use remote state.
#
# terraform {
#   backend "s3" {
#     bucket         = "portfolio-site-aderinto-adedayo-7684-tf-state"
#     key            = "terraform.tfstate"
#     region         = "af-south-1"
#     dynamodb_table = "portfolio-site-aderinto-adedayo-7684-tf-lock"
#     encrypt        = true
#   }
# }
