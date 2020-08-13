
###### COMMAND CENTRAL ###### 
resource "aws_security_group" "webmethods-commandcentral" {
  name        = "${module.global_common_base.name_prefix_short}-commandcentral"
  description = "Command Central"
  vpc_id      = module.management_common_base_network.network.id

  ingress {
    from_port   = 8090
    to_port     = 8093
    protocol    = "tcp"
    cidr_blocks = [module.management_common_base_network.network.cidr_block]
  }

  ## SPM communication outbound
  egress {
    from_port   = 8092
    to_port     = 8093
    protocol    = "tcp"
    cidr_blocks = [module.management_common_base_network.network.cidr_block]
  }

  ## SSH comm outbound for wM component bootstrapping
  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [module.management_common_base_network.network.cidr_block]
  }

  ## need to ideally figure out what port it needs to access...but seems like it needs to access many of the installed products
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [module.management_common_base_network.network.cidr_block]
  }

  //  Use our common tags and add a specific name.
  tags = merge(
    module.global_common_base.common_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-commandcentral"
      "az"   = "all"
    },
  )
}