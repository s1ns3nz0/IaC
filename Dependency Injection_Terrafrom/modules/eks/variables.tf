# modules/eks/variables.tf

variable "environment" {
  type = string
}

variable "cluster_name" {
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

variable "node_instance_type" {
  description = "EC2 instance type — injected per environment"
  type        = string
}

variable "desired_node_count" {
  description = "Desired number of nodes — injected per environment"
  type        = number
}

variable "min_node_count" {
  type    = number
  default = 1
}

variable "max_node_count" {
  type    = number
  default = 10
}

variable "enable_spot_instances" {
  description = "Use Spot instances — injected per environment"
  type        = bool
  default     = false
}