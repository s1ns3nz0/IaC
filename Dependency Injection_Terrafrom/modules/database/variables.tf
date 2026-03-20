# modules/database/variables.tf
# Receives VPC details — doesn't create them

variable "environment" {
  type = string
}

variable "vpc_id" {
  description = "Injected from networking module"
  type        = string
}

variable "subnet_ids" {
  description = "Injected from networking module"
  type        = list(string)
}

variable "table_name" {
  description = "DynamoDB table name"
  type        = string
}

variable "billing_mode" {
  description = "PAY_PER_REQUEST or PROVISIONED"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "enable_point_in_time_recovery" {
  description = "Enable PITR backup"
  type        = bool
  default     = true
}