/**
 * # Cloudtrail Reporter
 *
 * ## Description
 *
 * This module configures cloudtrail and reporting to a central monitoring hub
 *
 * ## Usage
 *
 * Use in combination with a report receiver deployed in central monitoring environment
 *
 * Resources:
 *
 * TODO update example

 ```hcl

  module "example" {
    source = "dod-iac/example/aws"

    tags = {
      Project     = var.project
      Application = var.application
      Environment = var.environment
      Automation  = "Terraform"
    }
  }

  ```

 *
 * ## Testing
 *
 * Run all terratest tests using the `terratest` script.  If using `aws-vault`, you could use `aws-vault exec $AWS_PROFILE -- terratest`.  The `AWS_DEFAULT_REGION` environment variable is required by the tests.  Use `TT_SKIP_DESTROY=1` to not destroy the infrastructure created during the tests.  Use `TT_VERBOSE=1` to log all tests as they are run.  Use `TT_TIMEOUT` to set the timeout for the tests, with the value being in the Go format, e.g., 15m.  The go test command can be executed directly, too.
 *
 * ## Terraform Version
 *
 * Terraform 0.13. Pin module version to ~> 1.0.0 . Submit pull-requests to master branch.
 *
 * Terraform 0.11 and 0.12 are not supported.
 *
 * ## License
 *
 * This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.
 *
 * ## Developer Setup
 *
 * This template is configured to use aws-vault, direnv, go, pre-commit, terraform-docs, and tfenv.  If using Homebrew on macOS, you can install the dependencies using the following code.
 *
 * ```shell
 * brew install aws-vault direnv go pre-commit terraform-docs tfenv
 * pre-commit install --install-hooks
 * ```
 *
 * If using `direnv`, add a `.envrc.local` that sets the default AWS region, e.g., `export AWS_DEFAULT_REGION=us-west-2`.
 *
 * If using `tfenv`, then add a `.terraform-version` to the project root dir, with the version you would like to use.
 *
 *
 */
// =================================================================
//
// Work of the U.S. Department of Defense, Defense Digital Service.
// Released as open source under the MIT License.  See LICENSE file.
//
// =================================================================

data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}
data "aws_iam_account_alias" "current" {}


resource "aws_cloudtrail" "this" {
  is_multi_region_trail         = true
  name                          = format("%s-cloudtrail", local.name_prefix)
  s3_bucket_name                = module.logging_bucket.id
  s3_key_prefix                 = format("%s-cloudtrail", local.name_prefix)
  include_global_service_events = var.include_global_service_events
  kms_key_id                    = module.s3_kms_key.aws_kms_key_arn
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.this.arn}:*"
  cloud_watch_logs_role_arn     = aws_iam_role.cloudwatch.arn
  enable_log_file_validation    = true
}
locals {
  bucket_prefix = format("%s-", data.aws_iam_account_alias.current.account_alias)
  bucket_id     = "${local.bucket_prefix}${format("%s-logging", local.name_prefix)}"
}
resource "aws_cloudwatch_log_group" "this" {
  name_prefix       = format("%s-cloudtrail-cloudwatch", local.name_prefix)
  tags              = var.tags
  kms_key_id        = module.cloudwatch_kms_key.aws_kms_key_arn
  retention_in_days = 1
}



data "aws_iam_policy_document" "this" {
  statement {
    sid       = "AWSCloudTrailAclCheck20211208"
    actions   = ["s3:GetBucketAcl"]
    effect    = "Allow"
    resources = ["arn:${data.aws_partition.current.partition}:s3:::${local.bucket_id}"]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

  }
  statement {
    sid       = "AWSCloudTrailWrite20211208"
    actions   = ["s3:PutObject"]
    resources = ["arn:${data.aws_partition.current.partition}:s3:::${local.bucket_id}/*"]
    effect    = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

#tfsec:ignore:aws-s3-enable-bucket-logging
module "logging_bucket" {
  source               = "trussworks/s3-private-bucket/aws"
  force_destroy = true
  bucket               = format("%s-logging", local.name_prefix)
  version              = ">=3.7.1"
  kms_master_key_id    = module.s3_kms_key.aws_kms_key_id
  custom_bucket_policy = data.aws_iam_policy_document.this.json
  sse_algorithm        = "aws:kms"
  enable_bucket_force_destroy = true

  tags = merge(var.tags, {
    Name = format("%s-cloudtrail-bucket", local.name_prefix)
    }
  )

  noncurrent_version_expiration = 90
  transitions = [
    {
      days          = 30
      storage_class = "STANDARD_IA"
    },
    {
      days          = 60
      storage_class = "GLACIER"
    },
    {
      days          = 150
      storage_class = "DEEP_ARCHIVE"
    }
  ]

  noncurrent_version_transitions = [
    {
      days          = 30
      storage_class = "STANDARD_IA"
    },
    {
      days          = 60
      storage_class = "GLACIER"
    }
  ]
}


module "s3_kms_key" {
  #source = "dod-iac/s3-kms-key/aws"
  source      = "git::https://github.com/dod-iac/terraform-aws-s3-kms-key"
  name        = format("alias/%s-logging-kms", local.name_prefix)
  description = format("A KMS key used to encrypt objects at rest in S3 for %s:%s.", local.application, local.environment)
  principals_extended = [
    { identifiers = ["cloudtrail.amazonaws.com"], type = "Service" }
  ]

  tags = var.tags
}

module "cloudwatch_kms_key" {
  source  = "dod-iac/cloudwatch-kms-key/aws"
  name    = "alias/name"
  tags    = var.tags
  version = "~>1.0"
}



resource "aws_iam_policy" "logging" {
  name        = format("%s-cloudtrail-logging", local.name_prefix)
  path        = "/"
  description = "IAM policy for logging from lambda"

  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          Resource = [aws_cloudwatch_log_group.this.arn, "${aws_cloudwatch_log_group.this.arn}:*"]
          Effect   = "Allow"
        },
        {
          Action   = ["kms:Encrypt", "kms:Decrypt"]
          Resource = [module.cloudwatch_kms_key.aws_kms_key_arn]
          Effect   = "Allow"

        }
      ]
    }
  )
}

resource "aws_iam_role" "cloudwatch" {
  name                = format("%s-cloudtrail-cloudwatch-role", local.name_prefix)
  managed_policy_arns = [aws_iam_policy.logging.arn]
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_cloudwatch_log_subscription_filter" "test_lambdafunction_logfilter" {
  name            = format("%s-cloudtrail-subscription", local.name_prefix)
  log_group_name  = aws_cloudwatch_log_group.this.name
  filter_pattern  = "{$.readOnly is FALSE}"
  destination_arn = var.kinesis_stream_arn
  distribution    = "Random"
}
