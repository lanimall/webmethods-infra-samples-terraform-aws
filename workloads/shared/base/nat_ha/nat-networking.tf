
resource "aws_eip" "natinstance" {
  count  = length(split(",", module.common_network.network_az_mapping[var.cloud_region]))
  
  vpc               = true
  network_interface = aws_network_interface.natinstance[count.index].id
  tags = merge(
    module.global_common_base.common_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-nat${count.index + 1}-${local.natinstance_subnets[count.index].availability_zone}"
      "az"   = local.natinstance_subnets[count.index].availability_zone
    },
  )
}

resource "aws_network_interface" "natinstance" {
  count  = length(split(",", module.common_network.network_az_mapping[var.cloud_region]))
  description       = "ENI for NAT instance"

  security_groups = flatten([
    module.common_network.common_securitygroup.id,
    [ 
      aws_security_group.natinstance.id 
    ]
  ])

  subnet_id         = local.natinstance_subnets[count.index].id
  
  ## important to disable for NATs
  source_dest_check = false
  
  //  Use our common tags and add a specific name.
  tags = merge(
    module.global_common_base.common_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-nat${count.index + 1}-${local.natinstance_subnets[count.index].availability_zone}"
      "az"   = local.natinstance_subnets[count.index].availability_zone
    },
  )
}

resource "aws_route" "private_nat" {
  count  = length(split(",", module.common_network.network_az_mapping[var.cloud_region]))

  route_table_id         = module.common_network.route_table_private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_network_interface.natinstance[count.index].id
}