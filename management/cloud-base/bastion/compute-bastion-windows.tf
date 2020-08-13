################################################
################ Outputs
################################################

output "bastion_windows-public_ip" {
  value = aws_eip.bastion_windows.*.public_ip
}

output "bastion_windows-public_dns" {
  value = aws_eip.bastion_windows.*.public_dns
}

output "bastion_windows-private_dns" {
  value = aws_instance.bastion_windows.*.private_dns
}

output "bastion_windows-private_ip" {
  value = aws_instance.bastion_windows.*.private_ip
}

################################################
################ Vars
################################################

variable "instancesize_bastion_windows" {
  description = "instance type for bastion"
}

variable "instancecount_bastion_windows" {
  description = "number of bastion nodes"
}

variable "hostname_bastion_windows" {
  description = "hostname"
}

locals {
  bastion_windows_tags = merge(
    module.global_common_base.common_tags,
    module.global_common_base_compute.common_instance_scheduler_tags,
    module.global_common_base_compute.common_instance_windows_tags,
    {}
  )

  bastion_windows_ips = aws_instance.bastion_windows.*.private_ip
}

################################################
################ DNS
################################################

resource "aws_route53_record" "bastion_windows" {
  count = var.instancecount_bastion_windows

  zone_id = module.management_common_base_network.dns_internal.zone_id
  name    = "${var.hostname_bastion_windows}${count.index + 1}.${module.global_common_base.name_prefix_long}.${module.management_common_base_network.dns_internal_apex}"
  type    = "A"
  ttl     = 300
  records = [
    aws_instance.bastion_windows[count.index].private_ip
  ]
}

################################################
################ VM specifics
################################################

// create eip for bastion_windows
resource "aws_eip" "bastion_windows" {
  count = var.instancecount_bastion_windows

  vpc = true

  //  Use our common tags and add a specific name.
  tags = merge(
    module.global_common_base.common_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-bastion_windows${count.index + 1}-${module.management_common_base_network.subnet_dmz[count.index].availability_zone}"
      "az"   = module.management_common_base_network.subnet_dmz[count.index].availability_zone
    },
  )
}

resource "aws_eip_association" "bastion_windows" {
  count = var.instancecount_bastion_windows
  
  instance_id   = aws_instance.bastion_windows[count.index].id
  allocation_id = aws_eip.bastion_windows[count.index].id
}

//Create the bastion userdata script.
data "template_file" "setup_bastion_windows" {
  count    = var.instancecount_bastion_windows
  template = file("./resources/setup-bastion-windows.ps1")
  vars = {
    availability_zone = element(split(",", module.management_common_base_network.network_az_mapping[local.region]), count.index)
  }
}

//  Launch configuration for the bastion
resource "aws_instance" "bastion_windows" {
  count = var.instancecount_bastion_windows

  subnet_id                   = module.management_common_base_network.subnet_dmz[count.index].id
  ami                         = module.global_common_base_compute.common_instance_windows_ami
  instance_type               = var.instancesize_bastion_windows
  user_data                   = data.template_file.setup_bastion_windows[count.index].rendered
  key_name                    = module.management_common_base_security.ssh_key_pair_bastion_id
  associate_public_ip_address = "true"

  vpc_security_group_ids = [aws_security_group.bastion_windows.id]

  //  Use our common tags and add a specific name.
  tags = merge(
    local.bastion_windows_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-bastion_windows${count.index + 1}-${module.management_common_base_network.subnet_dmz[count.index].availability_zone}"
      "az"   = module.management_common_base_network.subnet_dmz[count.index].availability_zone
    },
  )
}