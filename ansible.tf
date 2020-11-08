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

resource "null_resource" "foo" {
  depends_on = [vsphere_virtual_machine.jump]
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
    destination = var.ansible.inventory
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 ~/.ssh/${basename(var.jump.private_key_path)}",
    ]
  }
}
