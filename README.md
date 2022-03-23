<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
# Cloudtrail Reporter

## Description

This module configures cloudtrail and reporting to a central monitoring hub

## Usage

Use in combination with a report receiver deployed in central monitoring environment

Resources:

TODO update example

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.55 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.55 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloudwatch_kms_key"></a> [cloudwatch\_kms\_key](#module\_cloudwatch\_kms\_key) | dod-iac/cloudwatch-kms-key/aws | >1.0.0 |
| <a name="module_logging_bucket"></a> [logging\_bucket](#module\_logging\_bucket) | trussworks/s3-private-bucket/aws | >=3.7.1 |
| <a name="module_s3_kms_key"></a> [s3\_kms\_key](#module\_s3\_kms\_key) | git::https://github.com/dod-iac/terraform-aws-s3-kms-key.git | rms-extending-principals |

## Resources

| Name | Type |
|------|------|
| [aws_cloudtrail.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail) | resource |
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_subscription_filter.test_lambdafunction_logfilter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_subscription_filter) | resource |
| [aws_iam_policy.logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [random_string.prefix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_account_alias.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_account_alias) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_include_global_service_events"></a> [include\_global\_service\_events](#input\_include\_global\_service\_events) | n/a | `bool` | `true` | no |
| <a name="input_kinesis_stream_arn"></a> [kinesis\_stream\_arn](#input\_kinesis\_stream\_arn) | n/a | `string` | n/a | yes |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | n/a | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | <pre>object({<br>    Project     = string<br>    Environment = string<br>    Application = string<br>  })</pre> | <pre>{<br>  "Application": "infra",<br>  "Environment": "dev",<br>  "Project": "elmo"<br>}</pre> | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
