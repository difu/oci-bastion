terraform {
  required_version = ">= 1.5"
  required_providers {
    oci = {
      version = ">= 5.1.0"
    }
  }
}

provider "oci" {

}

module "bastion_example_vcn" {
  source = "oracle-terraform-modules/vcn/oci"

  # general oci parameters
  compartment_id = var.compartment_ocid

  # vcn parameters
  lockdown_default_seclist = false # boolean: true or false
}

resource "oci_core_network_security_group" "ebastion_nsg" {
  #Required
  compartment_id = var.compartment_ocid
  vcn_id         = module.bastion_example_vcn.vcn_id

  #Optional
  display_name = "NSG_Bastion"
}

resource "oci_core_subnet" "private_sub" {
  #Required
  cidr_block     = "10.0.0.0/24"
  compartment_id = var.compartment_ocid
  vcn_id         = module.bastion_example_vcn.vcn_id

  #Optional
  display_name               = "private-sub"
  dns_label                  = "privatesub"
  prohibit_public_ip_on_vnic = true
}

module "instance_flex" {
  source           = "oracle-terraform-modules/compute-instance/oci"
  # general oci parameters
  compartment_ocid = var.compartment_ocid

  cloud_agent_plugins = {
    autonomous_linux        = "ENABLED"
    bastion                 = "ENABLED"
    vulnerability_scanning  = "ENABLED"
    osms                    = "ENABLED"
    management              = "DISABLED"
    custom_logs             = "ENABLED"
    run_command             = "ENABLED"
    monitoring              = "ENABLED"
    block_volume_mgmt       = "DISABLED"
    java_management_service = "DISABLED"
  }
  instance_flex_ocpus = 1
  instance_state      = "RUNNING"
  source_ocid         = var.image_ocid
  subnet_ocids        = [oci_core_subnet.private_sub.id]
  ssh_public_keys     = file(var.ssh_public_keys)
}

resource "oci_bastion_bastion" "oci_bastion_demo" {

  bastion_type     = "STANDARD"
  compartment_id   = var.compartment_ocid
  target_subnet_id = oci_core_subnet.private_sub.id
  dns_proxy_status = "ENABLED"

  client_cidr_block_allow_list = [
    "0.0.0.0/0"
  ]
  name = "oci_bastion_demo"
}