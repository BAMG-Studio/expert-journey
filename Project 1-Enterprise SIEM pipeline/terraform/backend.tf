# =============================================================================
# Terraform Backend Configuration
# =============================================================================
# NOTE: Uncomment and configure for production use
# =============================================================================

# terraform {
#   backend "s3" {
#     bucket         = "your-terraform-state-bucket"
#     key            = "siem-pipeline/terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     dynamodb_table = "terraform-locks"
#   }
# }

# For local development, Terraform uses local backend by default
