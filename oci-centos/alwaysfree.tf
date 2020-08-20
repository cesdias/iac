variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}
variable "region" {}

locals {
  ssh_public_key = file("~/.ssh/id_rsa.pub")
}

provider "oci" {
  region           = var.region
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}

variable "ad_region_mapping" {
  type = map(string)

  default = {
	  sa-saopaulo-1 = 1
    us-ashburn-1 = 3
    uk-london-1 = 3
  }
}

variable "images" {
  type = map(string)

  default = {
	# Canonical-Ubuntu-20.04-2020.04.23-0
	sa-saopaulo-1	= "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaavxwpynowq2qsn6dwg7m2sodcmq3gp3zkkviiiggpntgudww43xxa"
  us-ashburn-1 = "ocid1.image.oc1.iad.aaaaaaaaw4ziurqwrg6je7eynzsl7jr2c6flqoa7pcasf5xpxihfuvvyfojq"
  uk-london-1 = "ocid1.image.oc1.uk-london-1.aaaaaaaatsmlapfs7bhnup3hnscdt7w33tlalpidliqk2ak6ixewy7vhjyda"
  }
}

data "oci_identity_availability_domain" "ad" {
  compartment_id = var.tenancy_ocid
  ad_number      = var.ad_region_mapping[var.region]
}

resource "oci_core_virtual_network" "free_vcn" {
  cidr_block     = "10.1.0.0/16"
  compartment_id = var.compartment_ocid
  display_name   = "FreeVCN"
  dns_label      = "freevcn"
}

resource "oci_core_subnet" "free_subnet" {
  cidr_block        = "10.1.20.0/24"
  display_name      = "FreeSubnet"
  dns_label         = "freesubnet"
  security_list_ids = [oci_core_security_list.free_security_list.id]
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_virtual_network.free_vcn.id
  route_table_id    = oci_core_route_table.free_route_table.id
  dhcp_options_id   = oci_core_virtual_network.free_vcn.default_dhcp_options_id
}

resource "oci_core_internet_gateway" "free_internet_gateway" {
  compartment_id = var.compartment_ocid
  display_name   = "freeIG"
  vcn_id         = oci_core_virtual_network.free_vcn.id
}

resource "oci_core_route_table" "free_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.free_vcn.id
  display_name   = "freeRouteTable"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.free_internet_gateway.id
  }
}

resource "oci_core_security_list" "free_security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.free_vcn.id
  display_name   = "freeSecurityList"

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  # icmp
  ingress_security_rules {
    protocol = "1"
    source   = "0.0.0.0/0"
  }

  # tcp
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      max = "22"
      min = "22"
    }
  }

  # tcp
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      max = "80"
      min = "80"
    }
  }

  # tcp
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      max = "443"
      min = "443"
    }
  }

  # udp
  ingress_security_rules {
    protocol = "17"
    source   = "0.0.0.0/0"

    udp_options {
      max = "53"
      min = "53"
    }
  }
}

resource "oci_core_instance" "free_instance1" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = var.compartment_ocid
  display_name        = "freeinstance1"
  shape               = "VM.Standard.E2.1.Micro"

  create_vnic_details {
    subnet_id        = oci_core_subnet.free_subnet.id
    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = "freeinstance1"
  }

  source_details {
    source_type = "image"
    source_id   = var.images[var.region]
  }

  metadata = {
    ssh_authorized_keys = local.ssh_public_key
  }
}

resource "oci_core_instance" "free_instance2" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = var.compartment_ocid
  display_name        = "freeinstance2"
  shape               = "VM.Standard.E2.1.Micro"

  create_vnic_details {
    subnet_id        = oci_core_subnet.free_subnet.id
    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = "freeinstance2"
  }

  source_details {
    source_type = "image"
    source_id   = var.images[var.region]
  }

  metadata = {
    ssh_authorized_keys = local.ssh_public_key
  }
}

data "oci_core_vnic_attachments" "freeinstance1_vnics" {
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domain.ad.name
  instance_id         = oci_core_instance.free_instance1.id
}

data "oci_core_vnic_attachments" "freeinstance2_vnics" {
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domain.ad.name
  instance_id         = oci_core_instance.free_instance2.id
}

data "oci_core_vnic" "freeinstance1_vnic" {
  vnic_id = lookup(data.oci_core_vnic_attachments.freeinstance1_vnics.vnic_attachments[0], "vnic_id")
}

data "oci_core_vnic" "freeinstance2_vnic" {
  vnic_id = lookup(data.oci_core_vnic_attachments.freeinstance2_vnics.vnic_attachments[0], "vnic_id")
}

output "free_instance1_ip" {
  value = data.oci_core_vnic.freeinstance1_vnic.public_ip_address
}

output "free_instance2_ip" {
  value = data.oci_core_vnic.freeinstance2_vnic.public_ip_address
}
