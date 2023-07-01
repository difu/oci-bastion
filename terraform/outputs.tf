output bastion_ocid {
  value = oci_bastion_bastion.oci_bastion_demo.id
}

output "instance_private_ip" {
  value = module.instance_flex.private_ip
}