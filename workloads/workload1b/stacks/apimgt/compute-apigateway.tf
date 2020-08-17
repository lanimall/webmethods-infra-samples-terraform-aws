################################################
################ Outputs
################################################

output "apigateway-private_dns" {
  value = aws_instance.apigateway.*.private_dns
}

output "apigateway-private_ip" {
  value = aws_instance.apigateway.*.private_ip
}

################################################
################ Vars
################################################

variable "apigateway_instancesize" {
  description = "instance type for bastion"
}

variable "apigateway_instancecount" {
  description = "number of bastion nodes"
}

variable "apigateway_hostname" {
  description = "hostname"
}

variable "apigateway_rootdisk_storage_type" {
  description = "root disk type"
}

variable "apigateway_datadisk_storage_type" {
  description = "app/data disk type"
}

variable "apigateway_datadisk_size_gb" {
  description = "app/data disk size (gb)"
}

locals {
  apigateway_tags = merge(
    module.global_common_base.common_tags,
    module.global_common_base_compute.common_instance_scheduler_tags,
    module.global_common_base_compute.common_instance_linux_tags,
    {}
  )

  apigateway_subnets = module.common_network.subnet_web
}

################################################
################ DNS
################################################

resource "aws_route53_record" "apigateway" {
  count = var.apigateway_instancecount

  zone_id = module.common_network.dns_internal.zone_id
  name    = "${var.apigateway_hostname}${count.index + 1}.${module.global_common_base.name_prefix_long}.${module.common_network.dns_internal_apex}"
  type    = "A"
  ttl     = 300
  records = [
    aws_instance.apigateway[count.index].private_ip
  ]
}

################################################
################ VM specifics
################################################

//Create the bastion userdata script.
data "template_file" "setup_apigateway" {
  count    = var.apigateway_instancecount
  template = file("./resources/setup-server.sh")
  vars = {
    availability_zone = element(split(",", module.common_network.network_az_mapping[local.region]), count.index)
  }
}

//  Launch configuration for the bastion
resource "aws_instance" "apigateway" {
  count = var.apigateway_instancecount

  subnet_id                   = local.apigateway_subnets[count.index%length(local.apigateway_subnets)].id
  ami                         = module.global_common_base_compute.common_instance_linux_ami
  instance_type               = var.apigateway_instancesize
  user_data                   = data.template_file.setup_apigateway[count.index].rendered
  key_name                    = module.common_security.ssh_key_pair_internalnode_id

  credit_specification {
    cpu_credits = "standard"
  }
    
  root_block_device {
    volume_type = var.apigateway_rootdisk_storage_type
    delete_on_termination = true
  }

  vpc_security_group_ids = flatten([
    module.common_network.common_securitygroup.id,
    [ 
      aws_security_group.apigateway.id
    ]
  ])

  //  Use our common tags and add a specific name.
  tags = merge(
    local.apigateway_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-${var.apigateway_hostname}${count.index + 1}-${local.apigateway_subnets[count.index%length(local.apigateway_subnets)].availability_zone}"
      "az"   = local.apigateway_subnets[count.index%length(local.apigateway_subnets)].availability_zone
    },
  )
}

resource "aws_volume_attachment" "apigateway" {
  count = var.apigateway_instancecount
  
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.apigateway[count.index].id
  instance_id = aws_instance.apigateway[count.index].id
}

resource "aws_ebs_volume" "apigateway" {
  count = var.apigateway_instancecount

  availability_zone = local.apigateway_subnets[count.index%length(local.apigateway_subnets)].availability_zone
  type              = var.apigateway_datadisk_storage_type
  size              = var.apigateway_datadisk_size_gb
  
  tags = merge(
    local.apigateway_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-${var.apigateway_hostname}${count.index + 1}-${local.apigateway_subnets[count.index%length(local.apigateway_subnets)].availability_zone}"
      "az"   = local.apigateway_subnets[count.index%length(local.apigateway_subnets)].availability_zone
    },
  )
}