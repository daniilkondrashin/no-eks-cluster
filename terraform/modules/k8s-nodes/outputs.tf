output "node_private_ips" {
  description = "Private IPs of all nodes"
  value = { for k, node in aws_instance.k8s_node : k => node.private_ip }
}

output "node_ids" {
  description = "IDs of all created nodes"
  value = { for k, node in aws_instance.k8s_node : k => node.id }
}
