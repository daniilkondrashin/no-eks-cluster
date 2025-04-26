output "bastion_public_ip" {
  description = "Public IP address of the bastion host"
  value       = aws_instance.bastion.public_ip
}

output "k8s_api_dns_name" {
  description = "DNS name of the Kubernetes API load balancer"
  value       = aws_lb.k8s_api.dns_name
}

output "k8s_api_url" {
  description = "URL to use in kubeconfig"
  value       = "https://k8s.${var.cloudflare_domain}:6443"
}

