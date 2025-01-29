# locals {
#   subnet_map = { for idx, cidr in var.subnet_cidrs : cidr => idx }
# }

resource "oci_core_vcn" "main" {
  compartment_id = var.compartment_id
  cidr_block     = var.cidr_block
  display_name   = "bet-vcn"
}
resource "oci_core_internet_gateway" "igw" {
  count = var.igw ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "internet-gateway"
  enabled        = true
}


resource "oci_core_subnet" "subnets" {
  for_each = { for idx, subnet in var.subnets : subnet.name => subnet }

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id

  display_name               = each.value.name
  cidr_block                 = each.value.cidr_block
  dns_label                  = try(each.value.dns_label, null)
  prohibit_public_ip_on_vnic = each.value.private
  security_list_ids          = [oci_core_security_list.public_security_list.id]
  route_table_id             = oci_core_route_table.public_route_table.id
}

resource "oci_core_security_list" "public_security_list" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "public-security-list"

  ingress_security_rules {
    protocol    = "6" # TCP
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    tcp_options {
      max = 22
      min = 22
    }
  }
  ingress_security_rules {
    protocol    = "6" # TCP
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    tcp_options {
      max = 8080
      min = 8080
    }
  }
  ingress_security_rules {
    protocol    = "6" # TCP
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    tcp_options {
      max = 443
      min = 443
    }
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}
resource "oci_core_route_table" "public_route_table" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "public-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw[0].id
  }
}

output "vcn_id" {
  value = oci_core_vcn.main.id
}

output "subnets_properties" {
  value       = oci_core_subnet.subnets
  description = "Export the Subnets properties"
}

# output "subnet_ids" {
#   value = { for name, subnet in oci_core_subnet.subnets : name => subnet.id }
# }
output "subnet_ids_list" {
  value = [for subnet in oci_core_subnet.subnets : {
    id      = subnet.id
    private = subnet.prohibit_public_ip_on_vnic
  }]
}

output "public_subnet_id" {
  value = join(",", [for subnet in oci_core_subnet.subnets : subnet.id if !subnet.prohibit_public_ip_on_vnic])
}

output "private_subnet_id" {
  value = join(",", [for subnet in oci_core_subnet.subnets : subnet.id if subnet.prohibit_public_ip_on_vnic])
}