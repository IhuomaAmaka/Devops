module "delegation_sets" {
  source  = "terraform-aws-modules/route53/aws//modules/delegation-sets"
  version = "~> 2.0"

  delegation_sets = {
    "myset" = {
      reference_name = "myset"
    }
  }
}

module "zones" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "~> 2.0"

  zones = {
    "assignmentfromnuvei.com" = {
      comment           = "assignmentfromnuvei.com"
      delegation_set_id = module.delegation_sets.route53_delegation_set_id["myset"]
    }
  }
}

module "route53_records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "2.10.1"

  records_jsonencoded = jsonencode([
    {
      name = "www"
      type = "CNAME"
      ttl  = 300
      records = [
        "10.10.10.10",
      ]
    }
  ])
  depends_on = [module.delegation_sets]
}

