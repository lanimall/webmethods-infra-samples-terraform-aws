################################################
################ Outputs
################################################

output "integrationserver-private_dns" {
  value = aws_instance.integrationserver.*.private_dns
}

output "integrationserver-private_ip" {
  value = aws_instance.integrationserver.*.private_ip
}

################################################
################ Vars
################################################

variable "integrationserver_instancesize" {
  description = "instance type for bastion"
}

variable "integrationserver_instancecount" {
  description = "number of bastion nodes"
}

variable "integrationserver_hostname" {
  description = "hostname"
}

variable "integrationserver_rootdisk_storage_type" {
  description = "root disk type"
}

variable "integrationserver_datadisk_storage_type" {
  description = "app/data disk type"
}

variable "integrationserver_datadisk_size_gb" {
  description = "app/data disk size (gb)"
}

locals {
  integrationserver_tags = merge(
    module.global_common_base.common_tags,
    module.global_common_base_compute.common_instance_scheduler_tags,
    module.global_common_base_compute.common_instance_linux_tags,
    {}
  )

  integrationserver_subnets = module.common_network.subnet_apps
}

################################################
################ DNS
################################################

resource "aws_route53_record" "integrationserver" {
  count = var.integrationserver_instancecount

  zone_id = module.common_network.dns_internal.zone_id
  name    = "${var.integrationserver_hostname}${count.index + 1}.${module.global_common_base.name_prefix_long}.${module.common_network.dns_internal_apex}"
  type    = "A"
  ttl     = 300
  records = [
    aws_instance.integrationserver[count.index].private_ip
  ]
}

################################################
################ VM specifics
################################################

//Create the bastion userdata script.
data "template_file" "setup_integrationserver" {
  count    = var.integrationserver_instancecount
  template = file("./resources/setup-server.sh")
  vars = {
    availability_zone = element(split(",", module.common_network.network_az_mapping[local.region]), count.index)
  }
}

//  Launch configuration for the bastion
resource "aws_instance" "integrationserver" {
  count = var.integrationserver_instancecount

  subnet_id                   = local.integrationserver_subnets[count.index%length(local.integrationserver_subnets)].id
  ami                         = module.global_common_base_compute.common_instance_linux_ami
  instance_type               = var.integrationserver_instancesize
  user_data                   = data.template_file.setup_integrationserver[count.index].rendered
  key_name                    = module.common_security.ssh_key_pair_internalnode_id
  associate_public_ip_address = "true"

  credit_specification {
    cpu_credits = "standard"
  }
    
  root_block_device {
    volume_type = var.integrationserver_rootdisk_storage_type
    delete_on_termination = true
  }

  vpc_security_group_ids = flatten([
    module.common_network.common_network_securitygroup,
    [ 
      aws_security_group.integrationserver.id
    ]
  ])

  //  Use our common tags and add a specific name.
  tags = merge(
    local.integrationserver_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-${var.integrationserver_hostname}${count.index + 1}-${local.integrationserver_subnets[count.index%length(local.integrationserver_subnets)].availability_zone}"
      "az"   = local.integrationserver_subnets[count.index%length(local.integrationserver_subnets)].availability_zone
    },
  )
}

resource "aws_volume_attachment" "integrationserver" {
  count = var.integrationserver_instancecount
  
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.integrationserver[count.index].id
  instance_id = aws_instance.integrationserver[count.index].id
}

resource "aws_ebs_volume" "integrationserver" {
  count = var.integrationserver_instancecount

  availability_zone = local.integrationserver_subnets[count.index%length(local.integrationserver_subnets)].availability_zone
  type              = var.integrationserver_datadisk_storage_type
  size              = var.integrationserver_datadisk_size_gb
  
  tags = merge(
    local.integrationserver_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-${var.integrationserver_hostname}${count.index + 1}-${local.integrationserver_subnets[count.index%length(local.integrationserver_subnets)].availability_zone}"
      "az"   = local.integrationserver_subnets[count.index%length(local.integrationserver_subnets)].availability_zone
    },
  )
}