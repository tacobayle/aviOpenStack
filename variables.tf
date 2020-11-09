#
# Environment Variables
#
variable "vsphere_user" {}
variable "vsphere_password" {}
variable "vsphere_server" {}
variable "docker_registry_username" {}
variable "docker_registry_password" {}
#
# Other Variables
#
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

variable "network" {
default     = "N1-T1_Segment-Backend_10.7.6.0-24"
}

variable "resource_pool" {
default     = "N1-Cluster1/Resources"
}

variable "wait_for_guest_net_timeout" {
  default = "5"
}

variable "compute" {
  default = {
    name = "os-compute"
    cpu = 16
    memory = 32768
    disk = 200
    public_key_path = "~/.ssh/cloudKey.pub"
    private_key_path = "~/.ssh/cloudKey"
    wait_for_guest_net_routable = "false"
    template_name = "ubuntu-bionic-18.04-cloudimg-template"
    ipCidrMgmt = ["10.206.112.59/22", "10.206.112.124/22"]
    ipCidrData = ["100.64.129.5/24", "100.64.129.6/24"]
    netplanFile = "/etc/netplan/50-cloud-init.yaml"
    defaultGw = "10.206.112.1"
    dns = "10.206.8.130, 10.206.8.131"
    username = "ubuntu"
  }
}

variable "controller" {
  default = {
    name = "os-controller"
    cpu = 4
    memory = 8192
    disk = 100
    public_key_path = "~/.ssh/cloudKey.pub"
    private_key_path = "~/.ssh/cloudKey"
    wait_for_guest_net_routable = "false"
    template_name = "ubuntu-bionic-18.04-cloudimg-template"
    ipCidrMgmt = ["10.206.113.255/22"]
    ipCidrData = ["100.64.129.7/24"]
    netplanFile = "/etc/netplan/50-cloud-init.yaml"
    defaultGw = "10.206.112.1"
    dns = "10.206.8.130, 10.206.8.131"
    username = "ubuntu"
  }
}

variable "jump" {
  type = map
  default = {
    name = "jump"
    cpu = 2
    memory = 4096
    disk = 30
    public_key_path = "~/.ssh/cloudKey.pub"
    private_key_path = "~/.ssh/cloudKey"
    wait_for_guest_net_timeout = 2
    template_name = "ubuntu-bionic-18.04-cloudimg-template"
    avisdkVersion = "18.2.9"
    username = "ubuntu"
  }
}

variable "ansible" {
  type = map
  default = {
    aviPbAbsentUrl = "https://github.com/tacobayle/ansiblePbAviAbsent"
    aviPbAbsentTag = "v1.36"
    aviConfigureUrl = "https://github.com/tacobayle/aviConfigure"
    aviConfigureTag = "v2.12"
    version = "2.9.12"
    inventory = "multinode"
    directory = "ansible"
  }
}

variable "kolla" {
  type = map
  default = {
    distro = "ubuntu"
    type = "source"
    network_interface = "ens192"
    neutron_external_interface = "ens224"
    internal_vip_address = "10.206.112.121"
    globals =  "/etc/kolla/globals.yml"
    openStackVersion = "train"
  }
}
