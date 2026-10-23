# Terraform AWS EFS Module

A Terraform module for managing an [Amazon Elastic File System (EFS)](https://docs.aws.amazon.com/efs/latest/ug/whatisefs.html) file system together with its mount targets. The module can create either a One Zone or a Regional file system, optionally encrypt it with a customer managed KMS key, tune performance and throughput, and expose the file system to one or more subnets through mount targets.

## Features

- **One Zone or Regional**: Creates a One Zone file system pinned to a single Availability Zone by default, or a Regional multi-AZ file system when `regional` is enabled.
- **KMS Encryption**: Enables encryption at rest automatically when a KMS key ARN or ID is supplied via `kms_id`.
- **Performance Mode**: Selects between the `generalPurpose` and `maxIO` performance modes.
- **Throughput Control**: Supports `bursting`, `elastic` and `provisioned` throughput, including a configurable provisioned rate in MiB/s.
- **Replication Overwrite Protection**: Sets the file system protection block so replication overwrite can be enabled or disabled.
- **Mount Targets**: Creates one mount target per supplied subnet ID and attaches the given security groups to each of them.

---

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

---

## Usage Examples

### Basic Example

Create a One Zone file system in the default Availability Zone with a single mount target:

```hcl
module "efs" {
  source = "git::https://github.com/virsas/terraform-aws-efs.git?ref=v1.1"

  name = "vss-application-data"

  subnet_ids      = ["subnet-0abc123def4567890"]
  security_groups = ["sg-0abc123def4567890"]
}
```

### Advanced Example (Regional, Encrypted, Provisioned Throughput)

Create a Regional file system spread over three subnets, encrypted with a customer managed KMS key and using a provisioned throughput of 128 MiB/s:

```hcl
module "efs_regional" {
  source = "git::https://github.com/virsas/terraform-aws-efs.git?ref=v1.1"

  name     = "vss-application-shared"
  regional = true

  kms_id = "arn:aws:kms:eu-west-1:123456789012:key/12345678-1234-1234-1234-123456789012"

  performance_mode                = "maxIO"
  throughput_mode                 = "provisioned"
  provisioned_throughput_in_mibps = 128

  replication_overwrite = "DISABLED"

  subnet_ids = [
    "subnet-0abc123def4567890",
    "subnet-0def456abc7890123",
    "subnet-0123abc456def7890"
  ]

  security_groups = ["sg-0abc123def4567890"]
}
```

### One Zone Example (Custom Availability Zone)

Pin a One Zone file system to a specific Availability Zone and reuse the default bursting throughput:

```hcl
module "efs_one_zone" {
  source = "git::https://github.com/virsas/terraform-aws-efs.git?ref=v1.1"

  name     = "vss-application-scratch"
  regional = false
  zone     = "eu-west-1b"

  performance_mode = "generalPurpose"
  throughput_mode  = "elastic"

  subnet_ids      = ["subnet-0def456abc7890123"]
  security_groups = ["sg-0abc123def4567890"]
}
```

---

## Resources

| Name | Type |
|------|------|
| [aws_efs_file_system.vss](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system) | resource |
| [aws_efs_mount_target.vss](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target) | resource |

---

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | The name tag applied to the EFS file system and used as its creation token. | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs where EFS mount targets will be created. Must contain at least one subnet ID. | `list(string)` | n/a | yes |
| <a name="input_regional"></a> [regional](#input\_regional) | Set to `true` to create a Regional (multi-AZ) file system, or `false` to create a One Zone file system. | `bool` | `false` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | Availability Zone name (e.g. `"eu-west-1a"`) for a One Zone file system. Required when `regional` is `false` and ignored when `regional` is `true`. | `string` | `"eu-west-1a"` | no |
| <a name="input_kms_id"></a> [kms\_id](#input\_kms\_id) | ARN or ID of the AWS KMS key used for encryption. Setting this enables encryption at rest on the file system. | `string` | `null` | no |
| <a name="input_performance_mode"></a> [performance\_mode](#input\_performance\_mode) | The file system performance mode. Allowed values: `generalPurpose` or `maxIO`. | `string` | `"generalPurpose"` | no |
| <a name="input_throughput_mode"></a> [throughput\_mode](#input\_throughput\_mode) | The throughput mode for the file system. Allowed values: `bursting`, `provisioned` or `elastic`. | `string` | `"bursting"` | no |
| <a name="input_provisioned_throughput_in_mibps"></a> [provisioned\_throughput\_in\_mibps](#input\_provisioned\_throughput\_in\_mibps) | Throughput in MiB/s provisioned for the file system. Must be greater than `0` when `throughput_mode` is `provisioned`, and is ignored otherwise. | `number` | `0` | no |
| <a name="input_replication_overwrite"></a> [replication\_overwrite](#input\_replication\_overwrite) | Whether replication overwrite protection is enabled on the file system. Allowed values: `ENABLED` or `DISABLED`. | `string` | `"ENABLED"` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | List of security group IDs to associate with every EFS mount target. | `list(string)` | n/a | yes |

---

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_url"></a> [url](#output\_url) | The ARN of the EFS file system. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the EFS file system. |
| <a name="output_dns_name"></a> [dns\_name](#output\_dns\_name) | The DNS name of the EFS file system. |
| <a name="output_name"></a> [name](#output\_name) | The value of the `Name` tag of the EFS file system. |
| <a name="output_number_of_mount_targets"></a> [number\_of\_mount\_targets](#output\_number\_of\_mount\_targets) | The current number of mount targets that the file system has. |
| <a name="output_owner_id"></a> [owner\_id](#output\_owner\_id) | The AWS account ID that owns the EFS file system. |
| <a name="output_size_in_bytes"></a> [size\_in\_bytes](#output\_size\_in\_bytes) | The latest known metered size of data stored in the file system, in bytes. |

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
