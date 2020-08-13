data "template_file" "setenv-management" {
  template = file("${path.cwd}/resources/setenv-management.template")
  vars = {
    management_linux_1_user                = var.common_compute_vm_linux.os_admin_user
    management_linux_1_hostname_private     = length(aws_instance.management_linux)>0 ? aws_instance.management_linux.0.private_ip : "null"
  }
}

resource "local_file" "setenv-management" {
  content  = data.template_file.setenv-management.rendered
  filename = join("/", [ pathexpand(var.env_output_dir), "setenv-management.sh" ] )
}