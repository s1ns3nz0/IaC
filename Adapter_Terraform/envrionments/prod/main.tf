# environments/prod/main.tf

# ── Using AWS ─────────────────────────────────────────────
module "storage" {
  source      = "../../modules/s3-adapter"

  bucket_name = "prod-bucket"
  versioning  = true
  region      = "ap-northeast-2"
}

# ── Switch to GCP — change ONE line only ──────────────────
module "storage" {
  source      = "../../modules/gcs-adapter"   # ← only this changes

  bucket_name = "prod-bucket"   # ← unchanged ✅
  versioning  = true            # ← unchanged ✅
  region      = "ap-northeast-2"# ← unchanged ✅
}