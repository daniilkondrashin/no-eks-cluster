output "bastion_ip" {
  value = module.bastion_lb.bastion_public_ip
}

output "k8s_api_url" {
  value = module.bastion_lb.k8s_api_url
}

output "node_ips" {
  value = module.k8s_nodes.node_private_ips
}

output "vpc_id" {
  value = module.network.vpc_id
}