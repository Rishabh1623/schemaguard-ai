# Main Terraform configuration for SchemaGuard AI
# 
# This file defines the core Terraform and AWS provider configuration
# Following AWS Well-Architected Framework best practices

terraform {
  required_version = ">= 1.5"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }
}

provider "aws" {
  region = var.aws_region

  # Apply default tags to all resources (cost tracking, governance)
  default_tags {
    tags = var.tags
  }
}
