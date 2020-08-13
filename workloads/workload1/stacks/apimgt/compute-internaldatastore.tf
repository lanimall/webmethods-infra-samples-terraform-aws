################################################
################ Outputs
################################################

output "internaldatastore-private_dns" {
  value = aws_instance.internaldatastore.*.private_dns
}

output "internaldatastore-private_ip" {
  value = aws_instance.internaldatastore.*.private_ip
}

################################################
################ Vars
################################################

variable "internaldatastore_instancesize" {
  description = "instance type for bastion"
}

variable "internaldatastore_instancecount" {
  description = "number of bastion nodes"
}

variable "internaldatastore_hostname" {
  description = "hostname"
}

variable "internaldatastore_rootdisk_storage_type" {
  description = "root disk type"
}

variable "internaldatastore_datadisk_storage_type" {
  description = "app/data disk type"
}

variable "internaldatastore_datadisk_size_gb" {
  description = "app/data disk size (gb)"
}

locals {
  internaldatastore_tags = merge(
    module.global_common_base.common_tags,
    module.global_common_base_compute.common_instance_scheduler_tags,
    module.global_common_base_compute.common_instance_linux_tags,
    {}
  )

  internaldatastore_subnets = module.common_network.subnet_data
}

################################################
################ DNS
################################################

resource "aws_route53_record" "internaldatastore" {
  count = var.internaldatastore_instancecount

  zone_id = module.common_network.dns_internal.zone_id
  name    = "${var.internaldatastore_hostname}${count.index + 1}.${module.global_common_base.name_prefix_long}.${module.common_network.dns_internal_apex}"
  type    = "A"
  ttl     = 300
  records = [
    aws_instance.internaldatastore[count.index].private_ip
  ]
}

################################################
################ VM specifics
################################################

//Create the bastion userdata script.
data "template_file" "setup_internaldatastore" {
  count    = var.internaldatastore_instancecount
  template = file("./resources/setup-server.sh")
  vars = {
    availability_zone = element(split(",", module.common_network.network_az_mapping[local.region]), count.index)
  }
}

//  Launch configuration for the bastion
resource "aws_instance" "internaldatastore" {
  count = var.internaldatastore_instancecount

  subnet_id                   = local.internaldatastore_subnets[count.index%length(local.internaldatastore_subnets)].id
  ami                         = module.global_common_base_compute.common_instance_linux_ami
  instance_type               = var.internaldatastore_instancesize
  user_data                   = data.template_file.setup_internaldatastore[count.index].rendered
  key_name                    = module.common_security.ssh_key_pair_internalnode_id
  associate_public_ip_address = "true"

  credit_specification {
    cpu_credits = "standard"
  }
    
  root_block_device {
    volume_type = var.internaldatastore_rootdisk_storage_type
    delete_on_termination = true
  }

  vpc_security_group_ids = flatten([
    module.common_network.common_network_securitygroup,
    [ 
      aws_security_group.apigateway_internaldatastore.id
    ]
  ])

  //  Use our common tags and add a specific name.
  tags = merge(
    local.internaldatastore_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-${var.internaldatastore_hostname}${count.index + 1}-${local.internaldatastore_subnets[count.index%length(local.internaldatastore_subnets)].availability_zone}"
      "az"   = local.internaldatastore_subnets[count.index%length(local.internaldatastore_subnets)].availability_zone
    },
  )
}

resource "aws_volume_attachment" "internaldatastore" {
  count = var.internaldatastore_instancecount
  
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.internaldatastore[count.index].id
  instance_id = aws_instance.internaldatastore[count.index].id
}

resource "aws_ebs_volume" "internaldatastore" {
  count = var.internaldatastore_instancecount

  availability_zone = local.internaldatastore_subnets[count.index%length(local.internaldatastore_subnets)].availability_zone
  type              = var.internaldatastore_datadisk_storage_type
  size              = var.internaldatastore_datadisk_size_gb
  
  tags = merge(
    local.internaldatastore_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-${var.internaldatastore_hostname}${count.index + 1}-${local.internaldatastore_subnets[count.index%length(local.internaldatastore_subnets)].availability_zone}"
      "az"   = local.internaldatastore_subnets[count.index%length(local.internaldatastore_subnets)].availability_zone
    },
  )
}