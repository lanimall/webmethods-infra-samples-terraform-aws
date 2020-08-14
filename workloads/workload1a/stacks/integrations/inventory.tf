data "template_file" "integrationserver_inventory_entry" {
  count    = length(aws_instance.integrationserver)
  template = file("${path.cwd}/resources/ansible-inventory-entry.template")
  vars = {
    alias = var.integrationserver_hostname
    index =  tostring(count.index + 1)
    ip = aws_instance.integrationserver[count.index].private_ip
    dns = aws_instance.integrationserver[count.index].private_dns
  }
}
data "template_file" "ansible_inventory" {
  template = file("${path.cwd}/resources/ansible-inventory.template")
  vars = {
    integrationserver_servers = join("\n", data.template_file.integrationserver_inventory_entry.*.rendered)
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