output "dns_main_internal_apex" {
  value = local.dns_main_internal_apex
}

output "dns_main_internal_zoneid" {
  value = aws_route53_zone.main-internal.id
}

locals {
  dns_main_internal_apex = substr(
    aws_route53_zone.main-internal.name,
    0,
    length(aws_route53_zone.main-internal.name) - 1,
  )
}

//Create the internal DNS.
resource "aws_route53_zone" "main-internal" {
  name    = var.resources_internal_dns_apex
  comment = "Main Internal DNS for demo project [${var.application_code}] - Managed by Terraform"
  vpc {
    vpc_id = aws_vpc.main.id
  }

  //  Use our common tags and add a specific name.
  tags = merge(
    module.global_common_base.common_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-Main Internal DNS"
    },
  )
}