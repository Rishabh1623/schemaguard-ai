# Core variables for SchemaGuard AI infrastructure

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "schemaguard-ai"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "us-east-1"
}

variable "bedrock_model_id" {
  description = "Amazon Bedrock model ID for agent reasoning"
  type        = string
  default     = "anthropic.claude-3-sonnet-20240229-v1:0"
}

variable "notification_email" {
  description = "Email for SNS notifications on schema drift events"
  type        = string
}

variable "glue_python_version" {
  description = "Python version for Glue jobs"
  type        = string
  default     = "3"
}

variable "glue_worker_type" {
  description = "Glue worker type (G.1X, G.2X, G.025X)"
  type        = string
  default     = "G.1X"
}

variable "glue_number_of_workers" {
  description = "Number of Glue workers"
  type        = number
  default     = 2
}

variable "schema_retention_days" {
  description = "Days to retain schema history in DynamoDB"
  type        = number
  default     = 90
}

variable "quarantine_retention_days" {
  description = "Days to retain quarantined data in S3"
  type        = number
  default     = 30
}

variable "enable_point_in_time_recovery" {
  description = "Enable DynamoDB point-in-time recovery"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project     = "SchemaGuard-AI"
    ManagedBy   = "Terraform"
    Purpose     = "Agentic-ETL-Platform"
  }
}
