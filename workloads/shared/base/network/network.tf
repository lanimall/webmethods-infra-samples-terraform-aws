output "vpc_id" {
  value = aws_vpc.main.id
}

output "availability_zones_mapping" {
  value = var.availability_zones_mapping
}

output "subnet_shortname_dmz" {
  value = var.subnet_shortname_dmz
}

output "subnet_shortname_web" {
  value = var.subnet_shortname_web
}

output "subnet_shortname_apps" {
  value = var.subnet_shortname_apps
}

output "subnet_shortname_data" {
  value = var.subnet_shortname_data
}

output "subnet_shortname_management" {
  value = var.subnet_shortname_management
}

//  Define the VPC.
resource "aws_vpc" "main" {
  cidr_block           = join(
    ".",
    [
      var.network_cidr_prefix,
      var.network_cidr_suffix
    ]
  )
  
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  //  Use our common tags and add a specific name.
  tags = merge(
    module.global_common_base.common_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-main"
    },
  )
}

###################
# Internet Gateway
###################

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  //  Use our common tags and add a specific name.
  tags = merge(
    module.global_common_base.common_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-main"
    },
  )
}

################
# Publiс routes
################

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  //  Use our common tags and add a specific name.
  tags = merge(
    module.global_common_base.common_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-public"
    },
  )
}

//  Create a route table allowing all addresses access to the IGW.
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id

  timeouts {
    create = "5m"
  }
}

#################
# Private routes
# There are as many routing tables as the number of NAT gateways
#################

resource "aws_route_table" "private" {
  count  = length(split(",", var.availability_zones_mapping[var.cloud_region]))
  vpc_id = aws_vpc.main.id

  //  Use our common tags and add a specific name.
  tags = merge(
    module.global_common_base.common_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-private-AZ${count.index + 1}"
      "az"   = element(split(",", var.availability_zones_mapping[var.cloud_region]), count.index)
    },
  )
}

########################### SUBNETS ####################################

###### COMMON DMZ ######
resource "aws_subnet" "dmz" {
  count                   = length(split(",", var.availability_zones_mapping[var.cloud_region]))
  vpc_id                  = aws_vpc.main.id
  availability_zone       = element(split(",", var.availability_zones_mapping[var.cloud_region]), count.index)
  map_public_ip_on_launch = false

  cidr_block = cidrsubnet(
    format(
      "%s.%s",
      var.network_cidr_prefix,
      var.subnet_allocation_map_suffixes[var.subnet_shortname_dmz_size],
    ),
    var.subnet_allocation_newbit_size[var.subnet_shortname_dmz_size],
    var.subnet_shortname_dmz_index * length(split(",", var.availability_zones_mapping[var.cloud_region])) + count.index,
  )

  //  Use our common tags and add a specific name.
  tags = merge(
    module.global_common_base.common_tags,
    {
      "Name"      = "${module.global_common_base.name_prefix_long}-${var.subnet_shortname_dmz}-AZ${count.index + 1}"
      "ShortName" = var.subnet_shortname_dmz
      "az"        = element(split(",", var.availability_zones_mapping[var.cloud_region]), count.index)
    },
  )
}

###### COMMON WEB ######
resource "aws_subnet" "web" {
  count                   = length(split(",", var.availability_zones_mapping[var.cloud_region]))
  vpc_id                  = aws_vpc.main.id
  availability_zone       = element(split(",", var.availability_zones_mapping[var.cloud_region]), count.index)
  map_public_ip_on_launch = false

  //cidr_block            = "${cidrsubnet(local.vpc_cidr, 10, count.index + 3 )}"

  cidr_block = cidrsubnet(
    format(
      "%s.%s",
      var.network_cidr_prefix,
      var.subnet_allocation_map_suffixes[var.subnet_shortname_web_size],
    ),
    var.subnet_allocation_newbit_size[var.subnet_shortname_web_size],
    var.subnet_shortname_web_index * length(split(",", var.availability_zones_mapping[var.cloud_region])) + count.index,
  )

  //  Use our common tags and add a specific name.
  tags = merge(
    module.global_common_base.common_tags,
    {
      "Name"      = "${module.global_common_base.name_prefix_long}-${var.subnet_shortname_web}-AZ${count.index + 1}"
      "ShortName" = var.subnet_shortname_web
      "az"        = element(split(",", var.availability_zones_mapping[var.cloud_region]), count.index)
    },
  )
}

###### COMMON APPS ######
resource "aws_subnet" "apps" {
  count                   = length(split(",", var.availability_zones_mapping[var.cloud_region]))
  vpc_id                  = aws_vpc.main.id
  availability_zone       = element(split(",", var.availability_zones_mapping[var.cloud_region]), count.index)
  map_public_ip_on_launch = false

  //cidr_block            = "${cidrsubnet(local.vpc_cidr, 10, count.index + 3 )}"

  cidr_block = cidrsubnet(
    format(
      "%s.%s",
      var.network_cidr_prefix,
      var.subnet_allocation_map_suffixes[var.subnet_shortname_apps_size],
    ),
    var.subnet_allocation_newbit_size[var.subnet_shortname_apps_size],
    var.subnet_shortname_apps_index * length(split(",", var.availability_zones_mapping[var.cloud_region])) + count.index,
  )

  //  Use our common tags and add a specific name.
  tags = merge(
    module.global_common_base.common_tags,
    {
      "Name"      = "${module.global_common_base.name_prefix_long}-${var.subnet_shortname_apps}-AZ${count.index + 1}"
      "ShortName" = var.subnet_shortname_apps
      "az"        = element(split(",", var.availability_zones_mapping[var.cloud_region]), count.index)
    },
  )
}

###### COMMON DATA ######
resource "aws_subnet" "data" {
  count                   = length(split(",", var.availability_zones_mapping[var.cloud_region]))
  vpc_id                  = aws_vpc.main.id
  availability_zone       = element(split(",", var.availability_zones_mapping[var.cloud_region]), count.index)
  map_public_ip_on_launch = false

  //cidr_block            = "${cidrsubnet(local.vpc_cidr, 10, count.index + 3 )}"

  cidr_block = cidrsubnet(
    format(
      "%s.%s",
      var.network_cidr_prefix,
      var.subnet_allocation_map_suffixes[var.subnet_shortname_data_size],
    ),
    var.subnet_allocation_newbit_size[var.subnet_shortname_data_size],
    var.subnet_shortname_data_index * length(split(",", var.availability_zones_mapping[var.cloud_region])) + count.index,
  )

  //  Use our common tags and add a specific name.
  tags = merge(
    module.global_common_base.common_tags,
    {
      "Name"      = "${module.global_common_base.name_prefix_long}-${var.subnet_shortname_data}-AZ${count.index + 1}"
      "ShortName" = var.subnet_shortname_data
      "az"        = element(split(",", var.availability_zones_mapping[var.cloud_region]), count.index)
    },
  )
}

###### COMMON MANAGEMENT ######
resource "aws_subnet" "mgt" {
  count                   = length(split(",", var.availability_zones_mapping[var.cloud_region]))
  vpc_id                  = aws_vpc.main.id
  availability_zone       = element(split(",", var.availability_zones_mapping[var.cloud_region]), count.index)
  map_public_ip_on_launch = false

  //cidr_block            = "${cidrsubnet(local.vpc_cidr, 10, count.index + 3 )}"

  cidr_block = cidrsubnet(
    format(
      "%s.%s",
      var.network_cidr_prefix,
      var.subnet_allocation_map_suffixes[var.subnet_shortname_management_size],
    ),
    var.subnet_allocation_newbit_size[var.subnet_shortname_management_size],
    var.subnet_shortname_management_index * length(split(",", var.availability_zones_mapping[var.cloud_region])) + count.index,
  )

  //  Use our common tags and add a specific name.
  tags = merge(
    module.global_common_base.common_tags,
    {
      "Name"      = "${module.global_common_base.name_prefix_long}-${var.subnet_shortname_management}-AZ${count.index + 1}"
      "ShortName" = var.subnet_shortname_management
      "az"        = element(split(",", var.availability_zones_mapping[var.cloud_region]), count.index)
    },
  )
}

##########################
# Route table association
##########################

//  Now associate the route table with the public subnet
resource "aws_route_table_association" "dmz" {
  count          = length(split(",", var.availability_zones_mapping[var.cloud_region]))
  subnet_id      = aws_subnet.dmz[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "web" {
  count          = length(split(",", var.availability_zones_mapping[var.cloud_region]))
  subnet_id      = element(aws_subnet.web.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

resource "aws_route_table_association" "apps" {
  count          = length(split(",", var.availability_zones_mapping[var.cloud_region]))
  subnet_id      = element(aws_subnet.apps.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

resource "aws_route_table_association" "data" {
  count          = length(split(",", var.availability_zones_mapping[var.cloud_region]))
  subnet_id      = element(aws_subnet.data.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

resource "aws_route_table_association" "mgt" {
  count          = length(split(",", var.availability_zones_mapping[var.cloud_region]))
  subnet_id      = element(aws_subnet.mgt.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}