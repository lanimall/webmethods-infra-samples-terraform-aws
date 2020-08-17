################################################
################ Outputs
################################################

# output "natinstance-public_ip" {
#   value = aws_instance.natinstance.*.public_ip
# }

# output "natinstance-public_dns" {
#   value = aws_instance.natinstance.*.public_dns
# }

# output "natinstance-private_dns" {
#   value = aws_instance.natinstance.*.private_dns
# }

# output "natinstance-private_ip" {
#   value = aws_instance.natinstance.*.private_ip
# }

################################################
################ Vars
################################################

variable "natinstance_instancesize" {
  description = "instance type for bastion"
}

variable "natinstance_hostname" {
  description = "hostname"
}

locals {
  natinstance_tags = merge(
    module.global_common_base.common_tags,
    module.global_common_base_compute.common_instance_scheduler_tags,
    {
      "OS_Family"         = "Linux"
      "OS_Architecture"   = "x86_64"
      "OS_Description"    = "AWS NAT Instance"
    }
  )

  natinstance_subnets = module.base_network.subnet_dmz
}

################################################
################ VM specifics
################################################

################################################
################ AMIs
################################################

// Find latest AWS Nat Instance AMI
data "aws_ami" "natinstance_aws_amis" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name   = "name"
        values = ["amzn-ami-vpc-nat-2018.03*"]
    }
}

################################################
################ Instance
################################################

//Create the bastion userdata script.
data "template_file" "setup_natinstance" {
  count  = length(split(",", module.base_network.network_az_mapping[var.cloud_region]))
  template = file("./resources/setup-natinstance.sh")
  vars = {
    availability_zone = element(split(",", module.base_network.network_az_mapping[local.region]), count.index)
  }
}

##use launch templates to re-create the nat instance if soemthing happens
resource "aws_launch_template" "natinstance" {
  count  = length(split(",", module.base_network.network_az_mapping[var.cloud_region]))
  name_prefix  = "${module.global_common_base.name_prefix_short}-natinstance"
  description = "Launch template for NAT instances"
  
  image_id      = data.aws_ami.natinstance_aws_amis.id
  instance_type = var.natinstance_instancesize
  user_data     = base64encode(data.template_file.setup_natinstance[count.index].rendered)
  instance_initiated_shutdown_behavior = "stop"

  iam_instance_profile {
    arn = aws_iam_instance_profile.natinstance.arn
  }

  network_interfaces {
    device_index         = 0
    network_interface_id = aws_network_interface.natinstance[count.index].id
  }

  credit_specification {
    cpu_credits = "standard"
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(
      local.natinstance_tags,
      {
        "Name" = "${module.global_common_base.name_prefix_long}-natinstance${count.index + 1}-${local.natinstance_subnets[count.index].availability_zone}"
        "az"   = local.natinstance_subnets[count.index].availability_zone
      },
    )
  }

  //  Use our common tags and add a specific name.
  tags = merge(
    module.global_common_base.common_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-natinstance"
    },
  )
}

//  Launch configuration for the bastion
# resource "aws_instance" "natinstance" {
#   count  = length(split(",", module.base_network.network_az_mapping[var.cloud_region]))

#   subnet_id                   = local.natinstance_subnets[count.index].id
#   ami                         = data.aws_ami.natinstance_aws_amis.id
#   instance_type               = var.natinstance_instancesize
  
#   key_name                    = module.base_security.ssh_key_pair_internalnode_id
#   associate_public_ip_address = true


#   //  Use our common tags and add a specific name.
#   tags = merge(
#     local.natinstance_tags,
#     {
#       "Name" = "${module.global_common_base.name_prefix_long}-natinstance${count.index + 1}-${local.natinstance_subnets[count.index].availability_zone}"
#       "az"   = local.natinstance_subnets[count.index].availability_zone
#     },
#   )
# }