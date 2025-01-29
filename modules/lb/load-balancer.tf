
#Load Balancer
resource "oci_load_balancer_load_balancer" "applayer_load_balancer" {
  #Required
  compartment_id = var.compartment_id
  display_name   = "lb-test"
  shape          = "flexible"
  is_private     = false
  ip_mode        = "IPV4"
  shape_details {
    maximum_bandwidth_in_mbps = 10
    minimum_bandwidth_in_mbps = 10
  }
  subnet_ids = compact([
    for subnet in var.subnet_ids : subnet.private == false ? subnet.id : ""
  ])
    
  
}
resource "oci_load_balancer_backend_set" "applayer_lb_backend_set" {
  name             = "backend-set"
  load_balancer_id = oci_load_balancer_load_balancer.applayer_load_balancer.id
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = var.lb-port 
    protocol            = "HTTP"
    response_body_regex = ".*"
    url_path            = "/"
  }
}
resource "oci_load_balancer_listener" "applayer_lb_listener" {
  load_balancer_id         = oci_load_balancer_load_balancer.applayer_load_balancer.id
  name                     = "http"
  default_backend_set_name = oci_load_balancer_backend_set.applayer_lb_backend_set.name
  port                     = var.lb-port 
  protocol                 = "HTTP"

  connection_configuration {
    idle_timeout_in_seconds = "240"
  }
}


# data "oci_core_subnets" "test_subnets" {
#   #Required
#   compartment_id = var.compartment_id

#   #Optional
#   vcn_id = var.vcn_id 
# }
output "id" {
  description = "The OCID of the load balancer"
  value       = oci_load_balancer_load_balancer.applayer_load_balancer.id
}
output "applayer_lb_backend_set_name" {
  description = "The OCID of the load balancer backend set"
  value       = oci_load_balancer_backend_set.applayer_lb_backend_set.name
}

