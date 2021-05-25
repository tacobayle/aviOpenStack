#
# Environment Variables
#
variable "vsphere_user" {}
variable "vsphere_password" {}
variable "vsphere_server" {}
variable "docker_registry_username" {}
variable "docker_registry_password" {}
variable "avi_googleId_20_1_4_qcow2" {}
variable "avi_user" {}
variable "avi_password" {}
#
# Other Variables
#
variable "vcenter" {
  type = map
  default = {
    dc = "sof2-01-vc08"
    cluster = "sof2-01-vc08c01"
    datastore = "sof2-01-vc08c01-vsan"
    resource_pool = "sof2-01-vc08c01/Resources"
    folder = "NicOpenStack"
    networkMgmt = "vxw-dvs-34-virtualwire-3-sid-1080002-sof2-01-vc08-avi-mgmt"
    networkData = "vxw-dvs-34-virtualwire-116-sid-1080115-sof2-01-vc08-avi-dev112"
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
    ipCidrMgmt = ["10.41.134.121/22", "10.41.134.122/22", "10.41.134.123/22"]
    netplanFile = "/etc/netplan/50-cloud-init.yaml"
    defaultGw = "10.41.132.1"
    dns = "10.23.108.1, 10.16.142.111"
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
    ipCidrMgmt = ["10.41.134.120/22"]
    netplanFile = "/etc/netplan/50-cloud-init.yaml"
    defaultGw = "10.41.132.1"
    dns = "10.23.108.1, 10.16.142.111"
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
    ipCidrData = "100.64.129.10/24"
  }
}

variable "ansible" {
  type = map
  default = {
    aviPbAbsentUrl = "https://github.com/tacobayle/ansiblePbAviAbsent"
    aviPbAbsentTag = "v1.36"
    aviConfigureUrl = "https://github.com/tacobayle/aviConfigure"
    aviConfigureTag = "v2.96"
    version = "2.9.12"
    inventory = "multinode"
    directory = "ansible"
    downloadGoogleDriveObjectUrl = "https://github.com/tacobayle/downloadGoogleDriveObject"
    downloadGoogleDriveObjectTag = "v1.00"
    jsonFileOpenStack = "~/fromTfOpenStack.json"
    osAviControllerUrl = "https://github.com/tacobayle/osAviController"
    osAviControllerTag = "v1.38"
    osInventoryUrl = "https://raw.githubusercontent.com/openstack/ansible-collections-openstack/master/scripts/inventory/openstack_inventory.py"
    yamlFile = "~/fromTf.yml"
  }
}

variable "kolla" {
  type = map
  default = {
    distro = "ubuntu"
    type = "source"
    network_interface = "ens192"
    neutron_external_interface = "ens224"
    internal_vip_address = "10.41.134.124"
    globals =  "/etc/kolla/globals.yml"
    openStackVersion = "train"
    enable_neutron_provider_networks = "yes"
    admin_admin = "/etc/kolla/admin-openrc.sh"
    admin_avi = "/etc/kolla/avi-openrc.sh"
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
    project = {
      avi = {
        name = "avi"
        description = "Avi Controller Project"
        user = "useravi"
      }
      others = [
        {
          name = "projectA"
          description = "projectA"
          user = "userA"
        },
        {
          name = "projectB"
          description = "projectB"
          user = "userB"
        }
      ]
    }
    networks = {
      external = {
        cidr = "100.64.129.0/24"
        allocation_pool_start = "50"
        allocation_pool_end = "99"
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
        name = "Ubuntu-Bionic", # don't change the name
        fileName: "/tmp/bionic-server-cloudimg-i386.img"
        url: "https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-i386.img"
      },
    ]
    controllerPrivateIpsFile = "~/controllerPrivateIps.json"
    jsonInputFile = "~/fromTfOpenStack.json"
    jsonOutputFile = "~/openstack_configuration.json"
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
    dns =  ["8.8.8.8", "8.8.4.4"]
    ntp = ["95.81.173.155", "188.165.236.162"]
    floatingIp = "1.1.1.1"
    from_email = "avicontroller@avidemo.fr"
    se_in_provider_context = "true"
    tenant_access_to_provider_se = "true"
    tenant_vrf = "true"
    aviCredsJsonFile = "~/.avicreds.json"
    environment = "OpenStack"
    version: "20.1.2"
  }
}

variable "domain" {
  type = map
  default = {
    name = "os.avidemo.fr"
  }
}