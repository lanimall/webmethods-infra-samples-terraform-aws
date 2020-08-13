###### Deployer (Integration Server) ###### 
resource "aws_security_group" "wmdeployer" {
  name        = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, "deployer" ] )
  description = "Software AG Deployer (Integration Server)"
  vpc_id      = module.management_common_base_network.network.id

  ingress {
    from_port = 5555
    to_port   = 5555
    protocol  = "tcp"
    cidr_blocks = flatten(
      [
        module.management_common_base_network.network.cidr_block
      ]
    )
  }

  ingress {
    from_port = 9999
    to_port   = 9999
    protocol  = "tcp"
    cidr_blocks = flatten(
      [
        module.management_common_base_network.subnet_management.*.cidr_block
      ]
    )
  }

  ##SPM communication
  ingress {
    from_port   = 8092
    to_port     = 8093
    protocol    = "tcp"
    cidr_blocks = flatten(
      [
        module.management_common_base_network.subnet_management.*.cidr_block
      ]
    )
  }

  ### TODO: Need to figure out what exact port to allow in egress
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      module.management_common_base_network.network.cidr_block
    ]
  }

  //  Use our common tags and add a specific name.
  tags = merge(
    module.global_common_base.common_tags,
    {
      "Name" = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_long, "deployer" ] )
      "az"   = "all"
    },
  )
}

resource "aws_security_group" "wmtestserver" {
  name        = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, "wmtestserver" ] )
  description = "Software AG testserver (Integration Server)"
  vpc_id      = module.management_common_base_network.network.id

  ingress {
    from_port = 5555
    to_port   = 5555
    protocol  = "tcp"
    cidr_blocks = flatten(
      [
        module.management_common_base_network.network.cidr_block
      ]
    )
  }

  ingress {
    from_port = 9999
    to_port   = 9999
    protocol  = "tcp"
    cidr_blocks = flatten(
      [
        module.management_common_base_network.subnet_management.*.cidr_block
      ]
    )
  }

  ##SPM communication
  ingress {
    from_port   = 8092
    to_port     = 8093
    protocol    = "tcp"
    cidr_blocks = flatten(
      [
        module.management_common_base_network.subnet_management.*.cidr_block
      ]
    )
  }

  ### TODO: Need to figure out what exact port to allow in egress
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      module.management_common_base_network.network.cidr_block
    ]
  }

  //  Use our common tags and add a specific name.
  tags = merge(
    module.global_common_base.common_tags,
    {
      "Name" = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_long, "testserver" ] )
      "az"   = "all"
    },
  )
}

###### Jenkins ###### 
resource "aws_security_group" "jenkins" {
  name        = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, "jenkins" ] )
  description = "Jenkins Build Server"
  vpc_id      = module.management_common_base_network.network.id

  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    cidr_blocks = flatten(
      [
        module.management_common_base_network.network.cidr_block
      ]
    )
  }

  ##SPM communication
  ingress {
    from_port   = 8092
    to_port     = 8093
    protocol    = "tcp"
    cidr_blocks = flatten(
      [
        module.management_common_base_network.subnet_management.*.cidr_block
      ]
    )
  }

  ### TODO: Need to figure out what exact port to allow in egress
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      module.management_common_base_network.network.cidr_block
    ]
  }

  //  Use our common tags and add a specific name.
  tags = merge(
    module.global_common_base.common_tags,
    {
      "Name" = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_long, "jenkins" ] )
      "az"   = "all"
    },
  )
}