# Outputs for Terraform

output "jump IP is" {
  value = vsphere_virtual_machine.jump.default_ip_address
}

output "Controller IP(s) is/are" {
  value = var.controller.ipCidrMgmt.*
}

output "Compute IP(s) is/are" {
  value = var.compute.ipCidrMgmt.*
}

output "Horizon Dashboard URL" {
  value = "http://${var.controller.ipCidrMgmt.0}"
}