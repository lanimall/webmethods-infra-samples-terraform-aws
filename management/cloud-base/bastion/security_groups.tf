
//  Security group which allows SSH to bastion linux
//TODO: we should protect the from ips
resource "aws_security_group" "bastion_linux" {
  name        = "${module.global_common_base.name_prefix_short}-bastion_linux"
  description = "Security group for linux bastion ingress/egress (ssh)"
  vpc_id      = module.management_common_base_network.network.id

  //  SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.bastion_allowed_cidrs
  }

  //allow SSH from internal too
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [module.management_common_base_network.network.cidr_block]
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [module.management_common_base_network.network.cidr_block]
  }

  //egress to public - TODO: TEMP?
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // TEMP - Allow all TCP egress because we need to monitor ports from ansible etc...
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
      "Name" = "${module.global_common_base.name_prefix_long}-bastion_linux"
      "az"   = "all"
    },
  )
}

//  Security group which allows RDP to bastion windows
//TODO: we should protect the from ips
resource "aws_security_group" "bastion_windows" {
  name        = "${module.global_common_base.name_prefix_short}-bastion_windows"
  description = "Security group for windows bastion ingress/egress (rdp)"
  vpc_id      = module.management_common_base_network.network.id

  //  HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.bastion_allowed_cidrs
  }

  //RDP
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = var.bastion_allowed_cidrs
  }

  ingress {
    from_port   = 3391
    to_port     = 3391
    protocol    = "udp"
    cidr_blocks = var.bastion_allowed_cidrs
  }

  //allow RDP from internal too
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = [module.management_common_base_network.network.cidr_block]
  }

  egress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = [module.management_common_base_network.network.cidr_block]
  }

  //egress to public - TODO: TEMP?
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // TEMP - Allow all TCP egress because we need to monitor ports from ansible etc...
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
      "Name" = "${module.global_common_base.name_prefix_long}-bastion_windows"
      "az"   = "all"
    },
  )
}

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
    cidr_blocks = formatlist("%s/32", aws_instance.bastion_linux.*.private_ip)
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
    cidr_blocks = formatlist("%s/32", aws_instance.bastion_windows.*.private_ip)
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