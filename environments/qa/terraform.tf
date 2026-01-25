terraform {
    required_version = ">= 1.0.0"

    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = ">= 5.0"
        }
    }

    backend "s3" {
        bucket         = "qa-hollywood-terraform-state"
        key            = "qa/us-east-2/terraform.tfstate"
        region         = "us-east-1"
        encrypt        = true
        use_lockfile   = true
        # profile        = "default"  # or "personal", "hollywood"
    }
}

provider "aws" {
  alias   = "qa"
  region  = "us-east-1"
  # profile = "default"  # or "personal", "hollywood"

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = "qa"
      Terraform   = "true"
      ManagedBy   = "terraform"
      Region      = var.aws_region
    }
  }
}