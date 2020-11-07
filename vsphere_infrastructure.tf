data "vsphere_datacenter" "dc" {
  name = var.vcenter.dc
}

data "vsphere_compute_cluster" "compute_cluster" {
  name          = var.vcenter.cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name = var.vcenter.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = var.vcenter.resource_pool
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_folder" "folder" {
  path          = var.vcenter.folder
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "networkMgmt" {
  name = var.vcenter.networkMgmt
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "networkData" {
  name = var.vcenter.networkMgmt
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_tag_category" "ansible_group_os-controller" {
  name = "ansible_group_os-controller"
  cardinality = "SINGLE"
  associable_types = [
    "VirtualMachine",
  ]
}

resource "vsphere_tag_category" "ansible_group_os-compute" {
  name = "ansible_group_os-compute"
  cardinality = "SINGLE"
  associable_types = [
    "VirtualMachine",
  ]
}