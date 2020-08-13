data "template_file" "buildserver_inventory_entry" {
  count    = length(aws_instance.buildserver)
  template = file("${path.cwd}/resources/ansible-inventory-entry.template")
  vars = {
    alias = var.buildserver_hostname
    index =  tostring(count.index + 1)
    ip = aws_instance.buildserver[count.index].private_ip
    dns = aws_instance.buildserver[count.index].private_dns
  }
}

data "template_file" "testserver_inventory_entry" {
  count    = length(aws_instance.testserver)
  template = file("${path.cwd}/resources/ansible-inventory-entry.template")
  vars = {
    alias = var.testserver_hostname
    index =  tostring(count.index + 1)
    ip = aws_instance.testserver[count.index].private_ip
    dns = aws_instance.testserver[count.index].private_dns
  }
}

data "template_file" "ansible_inventory" {
  template = file("${path.cwd}/resources/ansible-inventory.template")
  vars = {
    buildserver_servers = join("\n", data.template_file.buildserver_inventory_entry.*.rendered)
    testserver_servers = join("\n", data.template_file.testserver_inventory_entry.*.rendered)
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