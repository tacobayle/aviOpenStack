#
# Environment Variables
#
variable "vsphere_user" {}
variable "vsphere_password" {}
variable "vsphere_server" {}

variable "vcenter" {
  type = map
  default = {
    dc = "wdc-06-vc12"
    cluster = "wdc-06-vc12c01"
    datastore = "wdc-06-vc12c01-vsan"
    resource_pool = "wdc-06-vc12c01/Resources"
    folder = "NicOpenStack"
    networkMgmt = "vxw-dvs-34-virtualwire-3-sid-6120002-wdc-06-vc12-avi-mgmt"
    networkData = "vxw-dvs-34-virtualwire-116-sid-6120115-wdc-06-vc12-avi-dev112"
  }
}
#
variable "network" {
default     = "N1-T1_Segment-Backend_10.7.6.0-24"
}
#
variable "resource_pool" {
default     = "N1-Cluster1/Resources"
}
#
variable "wait_for_guest_net_timeout" {
  default = "5"
}
#
variable "compute" {
  default = {
    count = 2
    name = "OpenStack-Compute"
    cpu = 8
    memory = 8192
    disk = 100
    password = "Avi_2020"
    public_key_path = "~/.ssh/cloudKey.pub"
    private_key_path = "~/.ssh/cloudKey"
    wait_for_guest_net_routable = "false"
    template_name = "ubuntu-bionic-18.04-cloudimg-template"
    ipCidrMgmt = ["10.206.112.110/24", "10.206.112.111/24"]
    ipCidrData = ["100.64.129.5/24", "100.64.129.6/24"]
    netplanFile = "/etc/netplan/50-cloud-init.yaml"
    defaultGw = "10.206.112.1"
    dns = "10.206.8.130, 10.206.8.131"
  }
}
