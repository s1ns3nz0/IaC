# modules/s3-adapter/variables.tf
variable "bucket_name" { type = string }
variable "versioning"  { type = bool }
variable "region"      { type = string }