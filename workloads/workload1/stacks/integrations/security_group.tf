
###### Integration Server ###### 
resource "aws_security_group" "integrationserver" {
  name        = "${module.global_common_base.name_prefix_short}-is"
  description = "Software AG API Gateway Server"
  vpc_id      = module.common_network.network.id

  ingress {
    from_port = 5555
    to_port   = 5555
    protocol  = "tcp"
    cidr_blocks = flatten(
      [
        module.common_network.network.cidr_block
      ]
    )
  }

  ingress {
    from_port = 9999
    to_port   = 9999
    protocol  = "tcp"
    cidr_blocks = flatten(
      [
        module.common_network.network.cidr_block
      ]
    )
  }

  ingress {
    from_port = 9072
    to_port   = 9073
    protocol  = "tcp"
    cidr_blocks = flatten(
      [
        module.common_network.network.cidr_block
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
        module.common_network.network.cidr_block
      ]
    )
  }

  ### TODO: Need to figure out what exact port to allow in egress
  ### likely the elastic search node to node communication
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = flatten(
      [
        module.common_network.network.cidr_block
      ]
    )
  }

  //  Use our common tags and add a specific name.
  tags = merge(
    module.global_common_base.common_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-integration-server"
      "az"   = "all"
    },
  )
}

###### TERRACOTTA FOR integrationserver ###### 
resource "aws_security_group" "integrationserver_terracotta" {
  name        = "${module.global_common_base.name_prefix_short}-is-tc"
  description = "Terracotta for Integration Server Clustering"
  vpc_id      = module.common_network.network.id

  ## Terracotta ports
  ingress {
    from_port = 9510
    to_port   = 9510
    protocol  = "tcp"
    cidr_blocks = flatten(
      [
        module.common_network.network.cidr_block
      ]
    )
  }

  ingress {
    from_port = 9520
    to_port   = 9520
    protocol  = "tcp"
    cidr_blocks = flatten(
      [
        module.common_network.network.cidr_block
      ]
    )
  }

  ingress {
    from_port = 9530
    to_port   = 9530
    protocol  = "tcp"
    cidr_blocks = flatten(
      [
        module.common_network.network.cidr_block
      ]
    )
  }

  ingress {
    from_port = 9540
    to_port   = 9540
    protocol  = "tcp"
    cidr_blocks = flatten(
      [
        module.common_network.network.cidr_block
      ]
    )
  }

  ## TMC ports
  ingress {
    from_port = 9443
    to_port   = 9443
    protocol  = "tcp"
    cidr_blocks = flatten(
      [
        module.common_network.network.cidr_block
      ]
    )
  }

  ingress {
    from_port = 9889
    to_port   = 9889
    protocol  = "tcp"
    cidr_blocks = flatten(
      [
        module.common_network.network.cidr_block
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
        module.common_network.network.cidr_block
      ]
    )
  }

  ### TODO: Need to figure out what exact port to allow in egress
  ### likely the elastic search node to node communication
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = flatten(
      [
        module.common_network.network.cidr_block
      ]
    )
  }

  //Use our common tags and add a specific name.
  tags = merge(
    module.global_common_base.common_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-integrationserver-terracotta"
      "az"   = "all"
    },
  )
}

###### Universal Messaging FOR integrationserver ###### 
resource "aws_security_group" "integrationserver_universalmessaging" {
  name        = "${module.global_common_base.name_prefix_short}-is-um"
  description = "Universal Messaging for Integration Server Clustering"
  vpc_id      = module.common_network.network.id

  ## client ports...should be coming from APPS
  ingress {
    from_port = 9000
    to_port   = 9005
    protocol  = "tcp"
    cidr_blocks = flatten(
      [
        module.common_network.network.cidr_block
      ]
    )
  }

  ## UM node to node clustering channels
  ingress {
    from_port = 8888
    to_port   = 8888
    protocol  = "tcp"
    cidr_blocks = flatten(
      [
        module.common_network.network.cidr_block
      ]
    )
  }

  ingress {
    from_port = 9999
    to_port   = 9999
    protocol  = "tcp"
    cidr_blocks = flatten(
      [
        module.common_network.network.cidr_block
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
        module.common_network.network.cidr_block
      ]
    )
  }

  ### TODO: Need to figure out what exact port to allow in egress
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = flatten(
      [
        module.common_network.network.cidr_block
      ]
    )
  }

  //Use our common tags and add a specific name.
  tags = merge(
    module.global_common_base.common_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-integrationserver-universalmessaging"
      "az"   = "all"
    },
  )
}