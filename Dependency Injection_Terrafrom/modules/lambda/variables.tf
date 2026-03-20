# modules/lambda/variables.tf
# Receives EVERYTHING from outside — creates nothing itself

variable "environment" {
  type = string
}

variable "function_name" {
  type = string
}

variable "subnet_ids" {
  description = "Injected from networking module"
  type        = list(string)
}

variable "vpc_id" {
  description = "Injected from networking module"
  type        = string
}

variable "iam_role_arn" {
  description = "IAM role — injected from caller"
  type        = string
}

variable "environment_variables" {
  description = "Env vars — injected per environment"
  type        = map(string)
  default     = {}
}

variable "memory_size" {
  description = "Lambda memory in MB"
  type        = number
  default     = 256
}

variable "timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 30
}

variable "log_retention_days" {
  description = "CloudWatch log retention"
  type        = number
  default     = 30
}