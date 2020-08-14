data "template_file" "apigateway_inventory_entry" {
  count    = length(aws_instance.apigateway)
  template = file("${path.cwd}/resources/ansible-inventory-entry.template")
  vars = {
    alias = var.apigateway_hostname
    index =  tostring(count.index + 1)
    ip = aws_instance.apigateway[count.index].private_ip
    dns = aws_instance.apigateway[count.index].private_dns
  }
}

data "template_file" "internaldatastore_inventory_entry" {
  count    = length(aws_instance.internaldatastore)
  template = file("${path.cwd}/resources/ansible-inventory-entry.template")
  vars = {
    alias = var.internaldatastore_hostname
    index =  tostring(count.index + 1)
    ip = aws_instance.internaldatastore[count.index].private_ip
    dns = aws_instance.internaldatastore[count.index].private_dns
  }
}

data "template_file" "terracotta_inventory_entry" {
  count    = length(aws_instance.terracotta)
  template = file("${path.cwd}/resources/ansible-inventory-entry.template")
  vars = {
    alias = var.terracotta_hostname
    index =  tostring(count.index + 1)
    ip = aws_instance.terracotta[count.index].private_ip
    dns = aws_instance.terracotta[count.index].private_dns
  }
}

data "template_file" "apiportal_inventory_entry" {
  count    = length(aws_instance.apiportal)
  template = file("${path.cwd}/resources/ansible-inventory-entry.template")
  vars = {
    alias = var.apiportal_hostname
    index =  tostring(count.index + 1)
    ip = aws_instance.apiportal[count.index].private_ip
    dns = aws_instance.apiportal[count.index].private_dns
  }
}

data "template_file" "ansible_inventory" {
  template = file("${path.cwd}/resources/ansible-inventory.template")
  vars = {
    apigateway_servers = join("\n", data.template_file.apigateway_inventory_entry.*.rendered)
    apigwinternaldatastore_servers = join("\n", data.template_file.internaldatastore_inventory_entry.*.rendered)
    apigwterracotta_servers = join("\n", data.template_file.terracotta_inventory_entry.*.rendered)
    apiportal_servers = join("\n", data.template_file.apiportal_inventory_entry.*.rendered)
  }
}

resource "local_file" "ansible_inventory" {
  count    = (var.inventory_output_file_write == "true") ? 1 : 0
  
  content  = data.template_file.ansible_inventory.rendered
  filename = join("/", 
    [ 
      pathexpand(var.inventory_output_dir), 
      join("_", [ "inventory", module.global_common_base.name_prefix_long_nouuid ])
    ] 
  )
}