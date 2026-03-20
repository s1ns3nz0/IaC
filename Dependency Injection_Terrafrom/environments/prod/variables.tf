# environments/prod/variables.tf

variable "vpc_cidr" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "table_name" {
  type = string
}

variable "lambda_function_name" {
  type = string
}

variable "eks_cluster_name" {
  type = string
}