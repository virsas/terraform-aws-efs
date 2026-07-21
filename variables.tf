## EFS Variables

variable "name" {
  description = "The name tag applied to the EFS File System and used as its creation token."
  type        = string
}

variable "subnet_ids" {
  description = "A list of Subnet IDs where EFS Mount Targets will be created. At least one subnet ID is required."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "The 'subnet_ids' list must contain at least one subnet ID to create an EFS Mount Target."
  }
}

variable "regional" {
  description = "Set to true to create a Regional (multi-AZ) file system. Set to false (default) to create a One Zone file system."
  type        = bool
  default     = false
}

variable "zone" {
  description = "The Availability Zone ID (e.g., 'eu-west-1a') for a One Zone file system. Ignored if 'regional' is true."
  type        = string
  default     = "eu-west-1a"

  validation {
    condition     = var.regional || length(var.zone) > 0
    error_message = "The 'zone' variable is required when 'regional' is false (One Zone file system)."
  }
}

variable "kms_id" {
  description = "The ARN or ID of the AWS KMS Key to use for encryption. Setting this enables EFS encryption."
  type        = string
  default     = null
}

variable "performance_mode" {
  description = "The file system performance mode. Can be either 'generalPurpose' or 'maxIO' (Default: 'generalPurpose')."
  type        = string
  default     = "generalPurpose"

  validation {
    condition           = contains(["generalPurpose", "maxIO"], var.performance_mode)
    error_message       = "Expected values: generalPurpose, maxIO."
  }
}

variable "throughput_mode" {
  description = "The throughput mode for the file system. Can be 'bursting', 'provisioned', or 'elastic' (Default: 'bursting')."
  type        = string
  default     = "bursting"

  validation {
    condition = contains(["bursting", "provisioned", "elastic"], var.throughput_mode)
    error_message = "Expected values: bursting, provisioned, elastic."
  }
}

variable "provisioned_throughput_in_mibps" {
  description = "The throughput, measured in MiB/s, that you want to provision for the file system. Required and must be > 0 if 'throughput_mode' is 'provisioned'."
  type        = number
  default     = 0

  validation {
    condition = var.throughput_mode != "provisioned" || var.provisioned_throughput_in_mibps > 0
    error_message = "If 'throughput_mode' is 'provisioned', you must set a positive 'provisioned_throughput_in_mibps' value."
  }
}

variable "replication_overwrite" {
  description = "Indicates whether replication overwrite protection is enabled. Valid values: ENABLED or DISABLED."
  type        = string
  default     = "ENABLED"

  validation {
    condition           = contains(["ENABLED", "DISABLED"], var.replication_overwrite)
    error_message       = "Expected values: ENABLED, DISABLED."
  }
}

variable "security_groups" {
  description = "A list of Security Group IDs to associate with the EFS Mount Targets."
  type        = list(string)
}