resource "google_storage_bucket" "this" {
  name     = var.bucket_name
  location = upper(var.region)     # translate ✅

  versioning {
    enabled = var.versioning       # translate ✅
  }
}