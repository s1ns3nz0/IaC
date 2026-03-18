# The client stamps out every entry in the prototype registry.
# for_each is Terraform's clone loop —
# one real aws_instance per entry, each configured from its clone.

module "servers" {
  for_each = local.servers           # ← iterates over all clones

  source        = "./modules/server"
  name          = each.key                      # e.g. "web-server-1"
  instance_type = each.value.instance_type      # inherited or overridden
  storage_gb    = each.value.storage_gb         # inherited or overridden
  port          = each.value.port               # inherited or overridden
  env           = each.value.env                # inherited or overridden
  role          = each.value.role               # overridden per clone
}

output "all_instance_ids" {
  value = { for k, v in module.servers : k => v.instance_id }
}

---

#### What Gets Created
local.servers map                     Real AWS resources created
─────────────────────────────────     ─────────────────────────────────────
"web-server-1"  (t3.medium,  20GB) →  aws_instance: web-server-1
"web-server-2"  (t3.medium,  20GB) →  aws_instance: web-server-2
"db-server-1"   (r5.2xlarge,100GB) →  aws_instance: db-server-1
"staging-web"   (t3.medium,  20GB) →  aws_instance: staging-web

Every clone starts from `base_prototype`. Only the fields explicitly listed in `merge()` are different — all others are silently inherited.

---

#### Full Parallel Comparison
PYTHON                                   TERRAFORM
────────────────────────────────────     ──────────────────────────────────────
base_server = Server(                    base_prototype = {
  instance_type = "t3.medium",             instance_type = "t3.medium"
  storage_gb    = 20, ...                  storage_gb    = 20, ...
)                                        }

db = base_server.clone()                 "db-server-1" = merge(
db.instance_type = "r5.2xlarge"            local.base_prototype,
db.storage_gb    = 100                     { instance_type = "r5.2xlarge"
                                             storage_gb    = 100 }
                                         )

web.describe()                           module "servers" { for_each = local.servers }
db.describe()