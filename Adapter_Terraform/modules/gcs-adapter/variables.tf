# modules/gcs-adapter/variables.tf
variable "bucket_name" { type = string }   # same interface ✅
variable "versioning"  { type = bool }     # same interface ✅
variable "region"      { type = string }   # same interface ✅