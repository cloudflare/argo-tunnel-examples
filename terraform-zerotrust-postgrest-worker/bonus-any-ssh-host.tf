# this is bonus file, to switch to any SSH host, set the SSH host variables
# this resource will trigger connection to any SSH host and copy/run the installation script
resource "null_resource" "any_ssh_host" {
  # only run when var.ssh_host_ip is defined
  count = var.ssh_host_ip != "" ? 1 : 0

  # it will automatically rerun on any triggers change
  # or you can run `terraform taint "null_resource.any_ssh_host[0]"` which will plan resource to recreate
  triggers = {
    ip        = var.ssh_host_ip
    tunnel_id = cloudflare_argo_tunnel.auto_tunnel.id
  }

  connection {
    host        = var.ssh_host_ip
    port        = var.ssh_host_port
    user        = var.ssh_user
    private_key = fileexists(var.ssh_key_path) ? file(var.ssh_key_path) : ""
    password    = var.ssh_password
    timeout     = "600s" # 10 minutes should be enough to complete all steps, increase if needed
  }

  provisioner "file" {
    content     = local.startup_script
    destination = "/tmp/install-script.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install-script.sh",
      "/tmp/install-script.sh",
    ]
  }
}
