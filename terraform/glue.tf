# AWS Glue resources for ETL processing

# Glue Catalog Database
resource "aws_glue_catalog_database" "schemaguard" {
  name        = "${local.resource_prefix}_database"
  description = "SchemaGuard AI data catalog"

  tags = local.common_tags
}

# Glue ETL Job
resource "aws_glue_job" "etl_job" {
  name     = "${local.resource_prefix}-etl-job"
  role_arn = aws_iam_role.glue_job.arn

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket.scripts.id}/glue/etl_job.py"
    python_version  = var.glue_python_version
  }

  default_arguments = {
    "--job-language"                     = "python"
    "--job-bookmark-option"              = "job-bookmark-enable"
    "--enable-metrics"                   = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-spark-ui"                  = "true"
    "--spark-event-logs-path"            = "s3://${aws_s3_bucket.scripts.id}/spark-logs/"
    "--TempDir"                          = "s3://${aws_s3_bucket.scripts.id}/temp/"
    "--RAW_BUCKET"                       = aws_s3_bucket.raw.id
    "--STAGING_BUCKET"                   = aws_s3_bucket.staging.id
    "--CURATED_BUCKET"                   = aws_s3_bucket.curated.id
    "--QUARANTINE_BUCKET"                = aws_s3_bucket.quarantine.id
    "--CONTRACTS_BUCKET"                 = aws_s3_bucket.contracts.id
    "--SCHEMA_HISTORY_TABLE"             = aws_dynamodb_table.schema_history.name
    "--DATABASE_NAME"                    = aws_glue_catalog_database.schemaguard.name
    "--ENVIRONMENT"                      = var.environment
  }

  glue_version      = "4.0"
  worker_type       = var.glue_worker_type
  number_of_workers = var.glue_number_of_workers
  timeout           = 60
  max_retries       = 0

  execution_property {
    max_concurrent_runs = 3
  }

  tags = merge(
    local.common_tags,
    {
      Name = "SchemaGuard ETL Job"
    }
  )
}

# Glue Catalog Table for curated data
resource "aws_glue_catalog_table" "curated_data" {
  name          = "curated_data"
  database_name = aws_glue_catalog_database.schemaguard.name

  table_type = "EXTERNAL_TABLE"

  parameters = {
    "classification"  = "json"
    "compressionType" = "none"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.curated.id}/data/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      serialization_library = "org.openx.data.jsonserde.JsonSerDe"

      parameters = {
        "serialization.format" = "1"
      }
    }

    columns {
      name = "id"
      type = "string"
    }

    columns {
      name = "timestamp"
      type = "bigint"
    }

    columns {
      name = "data"
      type = "string"
    }
  }
}

# CloudWatch Log Group for Glue Job
resource "aws_cloudwatch_log_group" "glue_job" {
  name              = "/aws-glue/jobs/${aws_glue_job.etl_job.name}"
  retention_in_days = 30

  tags = local.common_tags
}
