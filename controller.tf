data "template_file" "controller_userdata" {
  count = length(var.controller.ipCidrMgmt)
  template = file("${path.module}/userdata/ubuntu.userdata")
  vars = {
    pubkey        = file(var.controller.public_key_path)
    ipCidrMgmt = element(var.controller.ipCidrMgmt, count.index)
    defaultGw = var.controller.defaultGw
    dns = var.controller.dns
    netplanFile = var.controller.netplanFile
    docker_registry_username = var.docker_registry_username
    docker_registry_password = var.docker_registry_password
    distro = var.kolla.distro
    openStackVersion = var.kolla.openStackVersion
    username = var.controller.username
  }
}

data "vsphere_virtual_machine" "controller" {
  name          = var.controller.template_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "controller" {
  count = length(var.controller.ipCidrMgmt)
  resource_pool_id = data.vsphere_resource_pool.pool.id
  name             = "${var.controller.name}-${count.index}"
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = vsphere_folder.folder.path
  network_interface {
    network_id = data.vsphere_network.networkMgmt.id
  }

  network_interface {
    network_id = data.vsphere_network.networkData.id
  }

  num_cpus = var.controller.cpu
  memory = var.controller.memory
  wait_for_guest_net_routable = var.controller.wait_for_guest_net_routable
  guest_id = data.vsphere_virtual_machine.controller.guest_id
  scsi_type = data.vsphere_virtual_machine.controller.scsi_type
  scsi_bus_sharing = data.vsphere_virtual_machine.controller.scsi_bus_sharing
  scsi_controller_count = data.vsphere_virtual_machine.controller.scsi_controller_scan_count
  nested_hv_enabled = true

  disk {
    size             = var.controller.disk
    label            = "controller-{count.index}.lab_vmdk"
    eagerly_scrub    = data.vsphere_virtual_machine.controller.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.controller.disks.0.thin_provisioned
  }

  cdrom {
    client_device = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.controller.id
  }

  vapp {
    properties = {
      hostname    = "${var.controller.name}-${count.index}"
      public-keys = file(var.controller.public_key_path)
      user-data   = base64encode(data.template_file.controller_userdata[count.index].rendered)
    }
  }

  connection {
    host        = split("/", element(var.controller.ipCidrMgmt, count.index))[0]
    type        = "ssh"
    agent       = false
    user        = var.controller.username
    private_key = file(var.controller.private_key_path)
  }

  provisioner "remote-exec" {
    inline      = [
      "while [ ! -f /tmp/cloudInitDone.log ]; do sleep 1; done"
    ]
  }

}