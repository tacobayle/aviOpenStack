#
# Environment Variables
#
variable "vsphere_user" {}
variable "vsphere_password" {}
variable "vsphere_server" {}
variable "docker_registry_username" {}
variable "docker_registry_password" {}
variable "avi_googleId_20_1_2_qcow2" {}
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

variable "wait_for_guest_net_timeout" {
  default = "5"
}

variable "ssh" {
  default = {
    public_key_file = "~/.ssh/cloudKey.pub"
  }
}

variable "compute" {
  default = {
    name = "os-compute"
    cpu = 32
    memory = 65536
    disk = 300
    public_key_path = "~/.ssh/cloudKey.pub"
    private_key_path = "~/.ssh/cloudKey"
    wait_for_guest_net_routable = "false"
    template_name = "ubuntu-bionic-18.04-cloudimg-template"
    ipCidrMgmt = ["10.206.112.59/22", "10.206.112.124/22"]
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
    netplanFile = "/etc/netplan/50-cloud-init.yaml"
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
    downloadGoogleDriveObjectUrl = "https://github.com/tacobayle/downloadGoogleDriveObject"
    downloadGoogleDriveObjectTag = "v1.00"
    jsonFileOpenStack = "~/fromTfOpenStack.json"
    osAviControllerUrl = "https://github.com/tacobayle/osAviController"
    osAviControllerTag = "v1.18"
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
    enable_neutron_provider_networks = "yes"
  }
}

variable "avi" {
  type = map
  default = {
    binFileName = "outputFile"
  }
}

variable "openstack" {
  default = {
    networks = {
      external = {
        cidr = "100.64.129.0/24"
        allocation_pool_start = "70"
        allocation_pool_end = "89"
        name = "net-ext"
        subnet = "subnet-ext"
      }
      internal = [
        {
          name = "net-avicontroller",
          subnet = "subnet-avicontroller",
          cidr = "192.168.10.0/24"
        },
        {
          name = "net-avise",
          subnet = "subnet-avise",
          cidr = "192.168.11.0/24",
          shared = "true"
        },
      ]
    }
    router = {
      name = "router-avi"
      interfaces = [
        {
          net = "net-avicontroller",
          subnet = "subnet-avicontroller"
        },
        {
          net = "net-avise",
          subnet = "subnet-avise"
        }
      ]
    }
    key = [
      {
        name = "keyPairsAviController",
        public_key_file: "/home/ubuntu/.ssh/cloudKey.pub"
      }
    ]
    glance = [ # keep Avi in the first position and Ubuntu Bionic in the second position in this list
      {
        name = "Avi-Controller",
        fileName: "/tmp/controller.qcow2"
      },
      {
        name = "Ubuntu-Bionic",
        fileName: "/tmp/bionic-server-cloudimg-i386.img"
        url: "https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-i386.img"
      },
    ]
  }
}

# the following will use to spin up Avi controller(s) in OpenStack

variable "avi_controller" {
  default = {
    flavor = "aviSmall"
    key = "keyPairsAviController"
    securitygroup = "sg-avicontroller" # don't change the name - created automatically
    network = "net-avicontroller"
    image = "Avi-Controller"
    Ips = ["192.168.10.11"] # the amount of controller is defined based on the length of this list
  }
}