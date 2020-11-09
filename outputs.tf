# Outputs for Terraform

output "jump_IP" {
  value = vsphere_virtual_machine.jump.default_ip_address
}

output "OpenStack_Controller_IP" {
  value = var.controller.ipCidrMgmt.*
}

output "OpenStack_Compute_IP" {
  value = var.compute.ipCidrMgmt.*
}

output "Horizon_Dashboard_URL" {
  value = "http://${var.kolla.internal_vip_address}"
}