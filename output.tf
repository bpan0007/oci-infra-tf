# output "subnets_properties" {
#   value       = module.vcn.subnets_properties 
#   description = "Export the Subnets properties"
# }
output "subnet_ids_list" {
  value = module.vcn.subnet_ids_list
}

output "lb_id" {
  value = module.load_balancer.id
}

output "backend_set_name" {
  value = module.load_balancer.applayer_lb_backend_set_name
}

output "public_subnet_id" {
  value       = module.vcn.public_subnet_id
  description = "public subnet" # Replace 0 with the index of the desired subnet
}
output "private_subnet_id" {
  value       = module.vcn.private_subnet_id
  description = "private subnet" # Replace 0 with the index of the desired subnet
}