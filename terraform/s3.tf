# S3 buckets for data pipeline stages

# Raw data landing zone
resource "aws_s3_bucket" "raw" {
  bucket = "${local.resource_prefix}-raw-${local.account_id}"

  tags = merge(
    local.common_tags,
    {
      Name  = "SchemaGuard Raw Data"
      Stage = "ingestion"
    }
  )
}

resource "aws_s3_bucket_versioning" "raw" {
  bucket = aws_s3_bucket.raw.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "raw" {
  bucket = aws_s3_bucket.raw.id

  rule {
    id     = "archive-old-data"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "INTELLIGENT_TIERING"
    }

    expiration {
      days = 90
    }
  }
}

# Quarantine bucket for problematic data
resource "aws_s3_bucket" "quarantine" {
  bucket = "${local.resource_prefix}-quarantine-${local.account_id}"

  tags = merge(
    local.common_tags,
    {
      Name  = "SchemaGuard Quarantine"
      Stage = "quarantine"
    }
  )
}

resource "aws_s3_bucket_lifecycle_configuration" "quarantine" {
  bucket = aws_s3_bucket.quarantine.id

  rule {
    id     = "expire-quarantine"
    status = "Enabled"

    expiration {
      days = var.quarantine_retention_days
    }
  }
}

# Curated/processed data
resource "aws_s3_bucket" "curated" {
  bucket = "${local.resource_prefix}-curated-${local.account_id}"

  tags = merge(
    local.common_tags,
    {
      Name  = "SchemaGuard Curated Data"
      Stage = "curated"
    }
  )
}

resource "aws_s3_bucket_versioning" "curated" {
  bucket = aws_s3_bucket.curated.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Staging bucket for validation
resource "aws_s3_bucket" "staging" {
  bucket = "${local.resource_prefix}-staging-${local.account_id}"

  tags = merge(
    local.common_tags,
    {
      Name  = "SchemaGuard Staging"
      Stage = "staging"
    }
  )
}

resource "aws_s3_bucket_lifecycle_configuration" "staging" {
  bucket = aws_s3_bucket.staging.id

  rule {
    id     = "cleanup-staging"
    status = "Enabled"

    expiration {
      days = 7
    }
  }
}

# Contracts bucket for schema versions
resource "aws_s3_bucket" "contracts" {
  bucket = "${local.resource_prefix}-contracts-${local.account_id}"

  tags = merge(
    local.common_tags,
    {
      Name  = "SchemaGuard Contracts"
      Stage = "governance"
    }
  )
}

resource "aws_s3_bucket_versioning" "contracts" {
  bucket = aws_s3_bucket.contracts.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Scripts bucket for Glue jobs and Lambda code
resource "aws_s3_bucket" "scripts" {
  bucket = "${local.resource_prefix}-scripts-${local.account_id}"

  tags = merge(
    local.common_tags,
    {
      Name  = "SchemaGuard Scripts"
      Stage = "deployment"
    }
  )
}

# Block public access for all buckets
resource "aws_s3_bucket_public_access_block" "raw" {
  bucket = aws_s3_bucket.raw.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "quarantine" {
  bucket = aws_s3_bucket.quarantine.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "curated" {
  bucket = aws_s3_bucket.curated.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "staging" {
  bucket = aws_s3_bucket.staging.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "contracts" {
  bucket = aws_s3_bucket.contracts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "scripts" {
  bucket = aws_s3_bucket.scripts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable encryption for all buckets
resource "aws_s3_bucket_server_side_encryption_configuration" "raw" {
  bucket = aws_s3_bucket.raw.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "quarantine" {
  bucket = aws_s3_bucket.quarantine.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "curated" {
  bucket = aws_s3_bucket.curated.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "staging" {
  bucket = aws_s3_bucket.staging.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "contracts" {
  bucket = aws_s3_bucket.contracts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "scripts" {
  bucket = aws_s3_bucket.scripts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# EventBridge notification for new raw data
resource "aws_s3_bucket_notification" "raw_data_events" {
  bucket      = aws_s3_bucket.raw.id
  eventbridge = true
}
