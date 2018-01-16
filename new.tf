#terraform apply -var-file=vars.tfvars

variable "provider"    {type = "list", description = "contains vars for openstack"}
variable "res_oci"     {type = "list", description = "contains vars for instance"}
variable "res_ons"     {type = "list", description = "contains vars for secgroup"}
variable "res_onsr"    {type = "list", description = "contains vars for secgroup rule"}
variable "volume_name" {description = "variable for name in blockstorage volume"}
variable "volume_size" {description = "variable for size in ablockstorage volume"}
variable "inst_id"     {description = "variable for instance_id in attach"}

provider "openstack" {
  tenant_name = "${var.provider[0]}"
  user_name   = "${var.provider[1]}"
  password    = "${var.provider[2]}"
  auth_url    = "${var.provider[3]}"
}

resource "openstack_compute_instance_v2" "basicA" {
  name            = "${var.res_oci[0]}"
  image_id        = "${var.res_oci[1]}"
  flavor_id       = "${var.res_oci[2]}"
  key_pair        = "${var.res_oci[3]}"
  security_groups = ["default", "secgroup_1_A"]

  network {
    name = "flat-provider-network"
  }

}

resource "openstack_networking_secgroup_v2" "secgroup_1_A" {
  name        = "${var.res_ons[0]}"
  description = "${var.res_ons[1]}"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_v4" {
  direction         = "${var.res_onsr[0]}"
  ethertype         = "${var.res_onsr[1]}"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_1_A.id}"
}

resource "openstack_blockstorage_volume_v2" "volume_1_A" {
  name = "${var.volume_name}"
  size = "${var.volume_size}"
}

resource "openstack_compute_volume_attach_v2" "va_1_A" {
  instance_id = "${var.inst_id}"
  volume_id   = "${openstack_blockstorage_volume_v2.volume_1_A.id}"
}

