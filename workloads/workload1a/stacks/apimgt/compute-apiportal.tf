################################################
################ Outputs
################################################

output "apiportal-private_dns" {
  value = aws_instance.apiportal.*.private_dns
}

output "apiportal-private_ip" {
  value = aws_instance.apiportal.*.private_ip
}

################################################
################ Vars
################################################

variable "apiportal_instancesize" {
  description = "instance type for bastion"
}

variable "apiportal_instancecount" {
  description = "number of bastion nodes"
}

variable "apiportal_hostname" {
  description = "hostname"
}

variable "apiportal_rootdisk_storage_type" {
  description = "root disk type"
}

variable "apiportal_datadisk_storage_type" {
  description = "app/data disk type"
}

variable "apiportal_datadisk_size_gb" {
  description = "app/data disk size (gb)"
}

locals {
  apiportal_tags = merge(
    module.global_common_base.common_tags,
    module.global_common_base_compute.common_instance_scheduler_tags,
    module.global_common_base_compute.common_instance_linux_tags,
    {}
  )

  apiportal_subnets = module.common_network.subnet_apps
}

################################################
################ DNS
################################################

resource "aws_route53_record" "apiportal" {
  count = var.apiportal_instancecount

  zone_id = module.common_network.dns_internal.zone_id
  name    = "${var.apiportal_hostname}${count.index + 1}.${module.global_common_base.name_prefix_long}.${module.common_network.dns_internal_apex}"
  type    = "A"
  ttl     = 300
  records = [
    aws_instance.apiportal[count.index].private_ip
  ]
}

################################################
################ VM specifics
################################################

//Create the bastion userdata script.
data "template_file" "setup_apiportal" {
  count    = var.apiportal_instancecount
  template = file("./resources/setup-server.sh")
  vars = {
    availability_zone = element(split(",", module.common_network.network_az_mapping[local.region]), count.index)
  }
}

//  Launch configuration for the bastion
resource "aws_instance" "apiportal" {
  count = var.apiportal_instancecount

  subnet_id                   = local.apiportal_subnets[count.index%length(local.apiportal_subnets)].id
  ami                         = module.global_common_base_compute.common_instance_linux_ami
  instance_type               = var.apiportal_instancesize
  user_data                   = data.template_file.setup_apiportal[count.index].rendered
  key_name                    = module.common_security.ssh_key_pair_internalnode_id
  associate_public_ip_address = "true"

  credit_specification {
    cpu_credits = "standard"
  }
    
  root_block_device {
    volume_type = var.apiportal_rootdisk_storage_type
    delete_on_termination = true
  }

  vpc_security_group_ids = flatten([
    module.common_network.common_network_securitygroup,
    [ 
      aws_security_group.apiportal.id
    ]
  ])

  //  Use our common tags and add a specific name.
  tags = merge(
    local.apiportal_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-${var.apiportal_hostname}${count.index + 1}-${local.apiportal_subnets[count.index%length(local.apiportal_subnets)].availability_zone}"
      "az"   = local.apiportal_subnets[count.index%length(local.apiportal_subnets)].availability_zone
    },
  )
}

resource "aws_volume_attachment" "apiportal" {
  count = var.apiportal_instancecount
  
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.apiportal[count.index].id
  instance_id = aws_instance.apiportal[count.index].id
}

resource "aws_ebs_volume" "apiportal" {
  count = var.apiportal_instancecount

  availability_zone = local.apiportal_subnets[count.index%length(local.apiportal_subnets)].availability_zone
  type              = var.apiportal_datadisk_storage_type
  size              = var.apiportal_datadisk_size_gb
  
  tags = merge(
    local.apiportal_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-${var.apiportal_hostname}${count.index + 1}-${local.apiportal_subnets[count.index%length(local.apiportal_subnets)].availability_zone}"
      "az"   = local.apiportal_subnets[count.index%length(local.apiportal_subnets)].availability_zone
    },
  )
}