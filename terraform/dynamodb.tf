# DynamoDB tables for schema history, approvals, and agent memory

# Schema history table - tracks all detected schema changes
resource "aws_dynamodb_table" "schema_history" {
  name           = "${local.resource_prefix}-schema-history"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "schema_id"
  range_key      = "timestamp"

  attribute {
    name = "schema_id"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "N"
  }

  attribute {
    name = "data_source"
    type = "S"
  }

  global_secondary_index {
    name            = "DataSourceIndex"
    hash_key        = "data_source"
    range_key       = "timestamp"
    projection_type = "ALL"
  }

  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  ttl {
    attribute_name = "expiration_time"
    enabled        = true
  }

  tags = merge(
    local.common_tags,
    {
      Name = "SchemaGuard Schema History"
    }
  )
}

# Contract approvals table - tracks human approval decisions
resource "aws_dynamodb_table" "contract_approvals" {
  name           = "${local.resource_prefix}-contract-approvals"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "contract_id"
  range_key      = "version"

  attribute {
    name = "contract_id"
    type = "S"
  }

  attribute {
    name = "version"
    type = "N"
  }

  attribute {
    name = "approval_status"
    type = "S"
  }

  global_secondary_index {
    name            = "ApprovalStatusIndex"
    hash_key        = "approval_status"
    range_key       = "contract_id"
    projection_type = "ALL"
  }

  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  tags = merge(
    local.common_tags,
    {
      Name = "SchemaGuard Contract Approvals"
    }
  )
}

# Agent memory table - stores agent decisions and learnings
resource "aws_dynamodb_table" "agent_memory" {
  name           = "${local.resource_prefix}-agent-memory"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "event_id"
  range_key      = "decision_timestamp"

  attribute {
    name = "event_id"
    type = "S"
  }

  attribute {
    name = "decision_timestamp"
    type = "N"
  }

  attribute {
    name = "schema_pattern"
    type = "S"
  }

  global_secondary_index {
    name            = "SchemaPatternIndex"
    hash_key        = "schema_pattern"
    range_key       = "decision_timestamp"
    projection_type = "ALL"
  }

  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  ttl {
    attribute_name = "expiration_time"
    enabled        = true
  }

  tags = merge(
    local.common_tags,
    {
      Name = "SchemaGuard Agent Memory"
    }
  )
}

# Execution state table - tracks Step Functions execution state
resource "aws_dynamodb_table" "execution_state" {
  name           = "${local.resource_prefix}-execution-state"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "execution_id"

  attribute {
    name = "execution_id"
    type = "S"
  }

  attribute {
    name = "status"
    type = "S"
  }

  attribute {
    name = "start_time"
    type = "N"
  }

  global_secondary_index {
    name            = "StatusIndex"
    hash_key        = "status"
    range_key       = "start_time"
    projection_type = "ALL"
  }

  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  ttl {
    attribute_name = "expiration_time"
    enabled        = true
  }

  tags = merge(
    local.common_tags,
    {
      Name = "SchemaGuard Execution State"
    }
  )
}
