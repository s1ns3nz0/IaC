# modules/lambda/variables.tf
variable "vpc_id"      { type = string }        # just accepts input
variable "subnet_ids"  { type = list(string) }  # just accepts input
variable "table_name"  { type = string }        # just accepts input
variable "function_name" { type = string }
variable "environment"   { type = string }