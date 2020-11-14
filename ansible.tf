data "template_file" "ipControl" {
  template = file("templates/ipControl.tmpl")
  count = length(var.controller.ipCidrMgmt)
  vars = {
    ipControl = split("/", element(var.controller.ipCidrMgmt, count.index))[0]
  }
}

data "template_file" "ipCompute" {
  template = file("templates/ipCompute.tmpl")
  count = length(var.compute.ipCidrMgmt)
  vars = {
    ipCompute = split("/", element(var.compute.ipCidrMgmt, count.index))[0]
  }
}

data "template_file" "multinode" {
  template = file("templates/multinode.tmpl")
  vars = {
    listControlIp = join("\n", data.template_file.ipControl.*.rendered)
    listComputeIp = join("\n", data.template_file.ipCompute.*.rendered)
    monitoring = split("/", element(var.controller.ipCidrMgmt, 0))[0]
  }
}

data "template_file" "globals" {
  template = file("templates/globals.yml.tmpl")
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
    source = var.jump.private_key_path
    destination = "~/.ssh/${basename(var.jump.private_key_path)}"
  }

  provisioner "file" {
    source = var.ssh.public_key_file
    destination = "/home/${var.jump.username}/.ssh/${basename(var.openstack.key[0].public_key_file)}"
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
      "cd ~ ; git clone ${var.ansible.downloadGoogleDriveObjectUrl} --branch ${var.ansible.downloadGoogleDriveObjectTag} ; cd ${split("/", var.ansible.downloadGoogleDriveObjectUrl)[4]} ; ansible-playbook local.yml --extra-vars 'googleDriveId=${var.avi_googleId_20_1_2_qcow2}' --extra-vars 'outputFile=${var.openstack.glance[0].fileName}'",
      "cd ~ ; wget ${var.openstack.glance[1].url} -O ${var.openstack.glance[1].fileName}",
      "/usr/local/bin/kolla-ansible post-deploy ; sudo chown ${var.jump.username}:${var.jump.username} ${var.kolla.admin_admin} ; chmod u+x ${var.kolla.admin_admin}",
      "cat ${var.kolla.admin_admin} | grep -v OS_PROJECT_NAME | tee ${var.kolla.admin_avi} ; echo 'export OS_PROJECT_NAME=${var.openstack.project.name}' | tee -a ${var.kolla.admin_avi}",
      "sleep 60",
    ]
  }

  provisioner "file" {
    content      = <<EOF
{"openstack": ${jsonencode(var.openstack)}, "avi_controller": ${jsonencode(var.avi_controller)}, "extDefaultGw": ${jsonencode(vsphere_virtual_machine.jump.guest_ip_addresses.2)}, "controllerPrivateIpsFile": ${var.openstack.controllerPrivateIpsFile}}
EOF
    destination = var.ansible.jsonFileOpenStack
  }

  provisioner "remote-exec" {
    inline = [
      "cat ${var.ansible.jsonFileOpenStack}",
      ". ${var.kolla.admin_admin}; cd ~ ; git clone ${var.ansible.osAviControllerUrl} --branch ${var.ansible.osAviControllerTag} ; cd ${split("/", var.ansible.osAviControllerUrl)[4]} ; ansible-playbook main.yml --extra-vars @${var.ansible.jsonFileOpenStack}",
    ]
  }

  provisioner "file" {
    content      = <<EOF
---
controller:
  environment: ${var.avi_controller.environment}
  username: ${var.avi_user}
  version: ${var.avi_controller.version}
  password: ${var.avi_password}
  count: ${length(var.avi_controller.Ips)}
  from_email: ${var.avi_controller.from_email}
  se_in_provider_context: ${var.avi_controller.se_in_provider_context}
  tenant_access_to_provider_se: ${var.avi_controller.tenant_access_to_provider_se}
  tenant_vrf: ${var.avi_controller.tenant_vrf}
  aviCredsJsonFile: ${var.avi_controller.aviCredsJsonFile}

ntpServers:
${yamlencode(var.avi_controller.ntp.*)}

dnsServers:
${yamlencode(var.avi_controller.dns.*)}

domain:
  name: ${var.domain.name}

EOF
    destination = var.ansible.yamlFile
  }

  provisioner "remote-exec" {
    inline      = [
      ". ${var.kolla.admin_avi}; cd ~ ; git clone ${var.ansible.aviConfigureUrl} --branch ${var.ansible.aviConfigureTag} ; cd ${split("/", var.ansible.aviConfigureUrl)[4]} ; ansible-playbook -i /home/${var.jump.username}/openstack_inventory.py local.yml --extra-vars @${var.ansible.yamlFile} --extra-vars @${var.openstack.controllerPrivateIpsFile}",
    ]
  }
}



