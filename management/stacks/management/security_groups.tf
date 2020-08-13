###### Management Server ###### 
### Security group for the management server: allow any egress within the VPC
######
resource "aws_security_group" "management_linux" {
  name        = "${module.global_common_base.name_prefix_short}-management_linux"
  description = "Management server for devops operations"
  vpc_id      = module.management_common_base_network.network.id

  //  SSH
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [module.management_common_base_network.network.cidr_block]
  }

  // Allow all TCP egress because we need to monitor ports from ansible etc...
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
      "Name" = "${module.global_common_base.name_prefix_long}-management_linux"
      "az"   = "all"
    },
  )
}

resource "aws_security_group" "management_windows" {
  name        = "${module.global_common_base.name_prefix_short}-management_windows"
  description = "Management server for devops operations"
  vpc_id      = module.management_common_base_network.network.id

  //  RDP
  ingress {
    from_port = 3389
    to_port   = 3389
    protocol  = "tcp"
    cidr_blocks = [module.management_common_base_network.network.cidr_block]
  }

  // Allow all TCP egress because we need to monitor ports from ansible etc...
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
      "Name" = "${module.global_common_base.name_prefix_long}-management_windows"
      "az"   = "all"
    },
  )
}