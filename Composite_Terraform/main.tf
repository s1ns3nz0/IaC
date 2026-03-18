# The ROOT only sees web_tier and data_tier.
# It has NO knowledge of vpc, ec2, or rds internally.
# This is exactly like calling .show() on the root folder —
# it recursively handles everything below.

module "web_tier" {
  source         = "./modules/web_tier"   # ← Composite
  name           = "prod-web"
  cidr_block     = "10.0.0.0/16"
  instance_count = 2
}

module "data_tier" {
  source     = "./modules/data_tier"      # ← Composite
  name       = "prod-data"
  cidr_block = "10.1.0.0/16"
}

# Root consumes outputs uniformly — doesn't matter how deep the tree is
output "web_public_ips" {
  value = module.web_tier.public_ips
}

output "db_endpoint" {
  value = module.data_tier.db_endpoint
}
```

---

### How It All Connects
```
root main.tf                          (ROOT Composite)
├── module "web_tier"                 (Composite)
│   ├── module "vpc"    → aws_vpc, aws_subnet, aws_igw   (Leaf)
│   └── module "ec2"    → aws_instance × 2               (Leaf)
└── module "data_tier"                (Composite)
    ├── module "vpc"    → aws_vpc, aws_subnet, aws_igw   (Leaf)
    └── module "rds"    → aws_db_instance                (Leaf)