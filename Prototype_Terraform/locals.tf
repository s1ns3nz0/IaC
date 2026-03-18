# This is the PROTOTYPE REGISTRY.
# Each entry is a fully configured prototype object.
# Clones inherit everything and override only what they need.

locals {

  # ── Base prototype (never deployed directly) ──────────────
  base_prototype = {
    instance_type = "t3.medium"
    region        = "ap-northeast-2"
    storage_gb    = 20
    port          = 80
    env           = "dev"
  }

  # ── Clones: merge base prototype + overrides ──────────────
  # merge() is Terraform's equivalent of .clone() + property override

  servers = {

    "web-server-1" = merge(local.base_prototype, {
      # Only overrides role — everything else inherited from base
      role = "web"
    })

    "web-server-2" = merge(local.base_prototype, {
      # Clone of web-server-1 logic, different name (key)
      role = "web"
    })

    "db-server-1" = merge(local.base_prototype, {
      # Overrides instance type and storage — rest inherited
      instance_type = "r5.2xlarge"
      storage_gb    = 100
      port          = 5432
      role          = "db"
    })

    "staging-web" = merge(local.base_prototype, {
      # Clones web config but changes env to staging
      role = "web"
      env  = "staging"
    })
  }
}