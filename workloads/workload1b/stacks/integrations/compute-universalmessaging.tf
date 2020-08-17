################################################
################ Outputs
################################################

output "universalmessaging-private_dns" {
  value = aws_instance.universalmessaging.*.private_dns
}

output "universalmessaging-private_ip" {
  value = aws_instance.universalmessaging.*.private_ip
}

################################################
################ Vars
################################################

variable "universalmessaging_instancesize" {
  description = "instance type for bastion"
}

variable "universalmessaging_instancecount" {
  description = "number of bastion nodes"
}

variable "universalmessaging_hostname" {
  description = "hostname"
}

variable "universalmessaging_rootdisk_storage_type" {
  description = "root disk type"
}

variable "universalmessaging_datadisk_storage_type" {
  description = "app/data disk type"
}

variable "universalmessaging_datadisk_size_gb" {
  description = "app/data disk size (gb)"
}

locals {
  universalmessaging_tags = merge(
    module.global_common_base.common_tags,
    module.global_common_base_compute.common_instance_scheduler_tags,
    module.global_common_base_compute.common_instance_linux_tags,
    {}
  )

  universalmessaging_subnets = module.common_network.subnet_apps
}

################################################
################ DNS
################################################

resource "aws_route53_record" "universalmessaging" {
  count = var.universalmessaging_instancecount

  zone_id = module.common_network.dns_internal.zone_id
  name    = "${var.universalmessaging_hostname}${count.index + 1}.${module.global_common_base.name_prefix_long}.${module.common_network.dns_internal_apex}"
  type    = "A"
  ttl     = 300
  records = [
    aws_instance.universalmessaging[count.index].private_ip
  ]
}

################################################
################ VM specifics
################################################

//Create the bastion userdata script.
data "template_file" "setup_universalmessaging" {
  count    = var.universalmessaging_instancecount
  template = file("./resources/setup-server.sh")
  vars = {
    availability_zone = element(split(",", module.common_network.network_az_mapping[local.region]), count.index)
  }
}

//  Launch configuration for the bastion
resource "aws_instance" "universalmessaging" {
  count = var.universalmessaging_instancecount

  subnet_id                   = local.universalmessaging_subnets[count.index%length(local.universalmessaging_subnets)].id
  ami                         = module.global_common_base_compute.common_instance_linux_ami
  instance_type               = var.universalmessaging_instancesize
  user_data                   = data.template_file.setup_universalmessaging[count.index].rendered
  key_name                    = module.common_security.ssh_key_pair_internalnode_id

  credit_specification {
    cpu_credits = "standard"
  }
    
  root_block_device {
    volume_type = var.universalmessaging_rootdisk_storage_type
    delete_on_termination = true
  }

  vpc_security_group_ids = flatten([
    module.common_network.common_securitygroup.id,
    [ 
      aws_security_group.integrationserver_universalmessaging.id
    ]
  ])

  //  Use our common tags and add a specific name.
  tags = merge(
    local.universalmessaging_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-${var.universalmessaging_hostname}${count.index + 1}-${local.universalmessaging_subnets[count.index%length(local.universalmessaging_subnets)].availability_zone}"
      "az"   = local.universalmessaging_subnets[count.index%length(local.universalmessaging_subnets)].availability_zone
    },
  )
}

resource "aws_volume_attachment" "universalmessaging" {
  count = var.universalmessaging_instancecount
  
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.universalmessaging[count.index].id
  instance_id = aws_instance.universalmessaging[count.index].id
}

resource "aws_ebs_volume" "universalmessaging" {
  count = var.universalmessaging_instancecount

  availability_zone = local.universalmessaging_subnets[count.index%length(local.universalmessaging_subnets)].availability_zone
  type              = var.universalmessaging_datadisk_storage_type
  size              = var.universalmessaging_datadisk_size_gb
  
  tags = merge(
    local.universalmessaging_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-${var.universalmessaging_hostname}${count.index + 1}-${local.universalmessaging_subnets[count.index%length(local.universalmessaging_subnets)].availability_zone}"
      "az"   = local.universalmessaging_subnets[count.index%length(local.universalmessaging_subnets)].availability_zone
    },
  )
}