data "template_file" "compute_userdata" {
  count = var.compute.count
  template = file("${path.module}/userdata/ubuntu.userdata")
  vars = {
    password      = var.compute["password"]
    pubkey        = file(var.compute["public_key_path"])
    ipCidrMgmt = element(var.compute.ipCidrMgmt, count.index)
    ipCidrData = element(var.compute.ipCidrData, count.index)
    defaultGw = var.compute["defaultGw"]
    dns = var.compute["dns"]
    netplanFile = var.compute["netplanFile"]
  }
}
#
data "vsphere_virtual_machine" "compute" {
  name          = var.compute["template_name"]
  datacenter_id = data.vsphere_datacenter.dc.id
}
#
resource "vsphere_virtual_machine" "ubuntu" {
  count = var.compute.count
  resource_pool_id = data.vsphere_resource_pool.pool.id
  name             = "${var.compute.name}-${count.index}"
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = vsphere_folder.folder.path
  network_interface {
                      network_id = data.vsphere_network.networkMgmt.id
  }

  network_interface {
                      network_id = data.vsphere_network.networkData.id
  }

  num_cpus = var.compute["cpu"]
  memory = var.compute["memory"]
  wait_for_guest_net_routable = var.compute["wait_for_guest_net_routable"]
  guest_id = data.vsphere_virtual_machine.compute.guest_id
  scsi_type = data.vsphere_virtual_machine.compute.scsi_type
  scsi_bus_sharing = data.vsphere_virtual_machine.compute.scsi_bus_sharing
  scsi_controller_count = data.vsphere_virtual_machine.compute.scsi_controller_scan_count

  disk {
    size             = var.compute["disk"]
    label            = "compute-{count.index}.lab_vmdk"
    eagerly_scrub    = data.vsphere_virtual_machine.compute.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.compute.disks.0.thin_provisioned
  }

  cdrom {
    client_device = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.compute.id
  }

  vapp {
    properties = {
     hostname    = var.compute["name"]
     password    = var.compute["password"]
     public-keys = file(var.compute["public_key_path"])
     user-data   = base64encode(data.template_file.compute_userdata[count.index].rendered)
   }
 }

  connection {
   host        = split("/", element(var.compute.ipCidrMgmt, count.index))[0]
   type        = "ssh"
   agent       = false
   user        = "ubuntu"
   private_key = file(var.compute["private_key_path"])
  }

  provisioner "remote-exec" {
   inline      = [
     "while [ ! -f /tmp/cloudInitDone.log ]; do sleep 1; done"
   ]
  }
}
