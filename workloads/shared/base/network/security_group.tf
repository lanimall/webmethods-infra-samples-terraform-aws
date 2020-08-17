output "aws_security_group_commoninternal_id" {
  value = aws_security_group.common-internal.id
}

output "aws_security_group_main_public_alb_id" {
  value = aws_security_group.main-public-alb.id
}

### ALB security group
resource "aws_security_group" "main-public-alb" {
  name        = "${module.global_common_base.name_prefix_short}-main-public-alb"
  description = "Incoming public web traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  //  Use our common tags and add a specific name.
  tags = merge(
    module.global_common_base.common_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-main-public-alb"
      "az"   = "all"
    },
  )
}

//  Security group which allows SSH/RDP access to a host from specific internal servers
resource "aws_security_group" "common-internal" {
  name        = "${module.global_common_base.name_prefix_short}-common-internal"
  description = "Security group for common internal rules (ssh, rdp)"
  vpc_id      = aws_vpc.main.id

  //  Use our common tags and add a specific name.
  tags = merge(
    module.global_common_base.common_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-Common Internal"
      "az"   = "all"
    },
  )
}

resource "aws_security_group_rule" "ingress_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [
    aws_vpc.main.cidr_block
  ]
  security_group_id = aws_security_group.common-internal.id
}

resource "aws_security_group_rule" "ingress_rdp" {
  type              = "ingress"
  from_port         = 3389
  to_port           = 3389
  protocol          = "tcp"
  cidr_blocks       = [
    aws_vpc.main.cidr_block
  ]
  security_group_id = aws_security_group.common-internal.id
}

resource "aws_security_group_rule" "egress_http" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.common-internal.id
}

resource "aws_security_group_rule" "egress_https" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.common-internal.id
}