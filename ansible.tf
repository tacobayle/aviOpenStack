data "template_file" "ipControl" {
  template = "${file("templates/ipControl.tmpl")}"
  count = length(var.controller.ipCidrMgmt)
  vars = {
    ipControl = split("/", element(var.controller.ipCidrMgmt, count.index))[0]
  }
}

data "template_file" "ipCompute" {
  template = "${file("templates/ipCompute.tmpl")}"
  count = length(var.compute.ipCidrMgmt)
  vars = {
    ipCompute = split("/", element(var.compute.ipCidrMgmt, count.index))[0]
  }
}

data "template_file" "multinode" {
  template = "${file("templates/multinode.tmpl")}"
  vars = {
    listControlIp = join("\n", data.template_file.ipControl.*.rendered)
    listComputeIp = join("\n", data.template_file.ipCompute.*.rendered)
    monitoring = split("/", element(var.controller.ipCidrMgmt, 0))[0]
  }
}

data "template_file" "globals" {
  template = "${file("templates/globals.yml.tmpl")}"
  vars = {
    distro = var.kolla.distro
    type = var.kolla.type
    network_interface = var.kolla.network_interface
    neutron_external_interface = var.kolla.neutron_external_interface
    internal_vip_address = var.kolla.internal_vip_address
    docker_registry_username = var.docker_registry_username
    enable_neutron_provider_networks = var.kolla.enable_neutron_provider_networks
  }
}

resource "null_resource" "foo" {
  depends_on = [vsphere_virtual_machine.jump, vsphere_virtual_machine.compute, vsphere_virtual_machine.controller]
  connection {
    host = vsphere_virtual_machine.jump.default_ip_address
    type = "ssh"
    agent = false
    user = "ubuntu"
    private_key = file(var.jump.private_key_path)
  }

  provisioner "file" {
    source = var.jump["private_key_path"]
    destination = "~/.ssh/${basename(var.jump.private_key_path)}"
  }

  provisioner "file" {
    content      = data.template_file.multinode.rendered
    destination = "/home/${var.jump.username}/${var.ansible.inventory}"
  }

  provisioner "file" {
    content      = data.template_file.globals.rendered
    destination = var.kolla.globals
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 ~/.ssh/${basename(var.jump.private_key_path)}",
      "cat ${var.kolla.globals}",
      "cat /etc/kolla/passwords.yml",
      "kolla-ansible -i /home/${var.jump.username}/${var.ansible.inventory} bootstrap-servers",
      "kolla-ansible -i /home/${var.jump.username}/${var.ansible.inventory} prechecks",
      "kolla-ansible -i /home/${var.jump.username}/${var.ansible.inventory} deploy",
      "/usr/local/bin/kolla-ansible post-deploy ; sudo chown ${var.jump.username}:${var.jump.username} /etc/kolla/admin-openrc.sh",
    ]
  }
}
