# modules/database/variables.tf
variable "vpc_id"      { type = string }        # just accepts input
variable "subnet_ids"  { type = list(string) }  # just accepts input
variable "table_name"  { type = string }