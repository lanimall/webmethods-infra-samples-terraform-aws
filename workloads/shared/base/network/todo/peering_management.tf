variable "peering_target_cidr" {
  description = "The CIDR block for the target peered VPC"
}

variable "peering_connection_id" {
  description = "The CIDR block for the target peered VPC"
}

output "peering_target_cidr" {
  value = var.peering_target_cidr
}

#################################
# Peering routes to the private route
#################################

resource "aws_route" "peering" {
  count  = length(split(",", var.availability_zones_mapping[var.cloud_region]))

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = var.peering_target_cidr
  vpc_peering_connection_id = var.peering_connection_id

  timeouts {
    create = "5m"
  }
}

resource "aws_security_group_rule" "peering_ingress_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [
    var.peering_target_cidr
  ]
  security_group_id = aws_security_group.common-internal.id
}

resource "aws_security_group_rule" "peering_ingress_rdp" {
  type              = "ingress"
  from_port         = 3389
  to_port           = 3389
  protocol          = "tcp"
  cidr_blocks       = [
    var.peering_target_cidr
  ]
  security_group_id = aws_security_group.common-internal.id
}

resource "aws_security_group_rule" "peering_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [
    var.peering_target_cidr
  ]
  security_group_id = aws_security_group.common-internal.id
}