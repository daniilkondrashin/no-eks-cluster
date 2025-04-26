variable "ami_id" {
  description = "AMI ID for the bastion host"
  type        = string
}

variable "instance_type" {
  description = "Instance type for bastion"
  type        = string
  default     = "t3.micro"
}

variable "ssh_key_name" {
  description = "SSH key pair name to access the bastion"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to private key file for SSH provisioner"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
}

variable "public_subnet_id" {
  description = "Subnet ID for bastion host"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnets for internal NLB"
  type        = list(string)
}

variable "master_private_ips" {
  description = "Private IP addresses of Kubernetes master nodes"
  type        = list(string)
}

variable "allowed_ip_cidr" {
  description = "CIDR block allowed to SSH into the bastion and access NLB"
  type        = string
}

variable "enable_vpn" {
  description = "Flag to enable VPN (WireGuard) setup on bastion"
  type        = bool
  default     = false
}

variable "cloudflare_token" {
  description = "Cloudflare API token"
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID"
  type        = string
}

variable "cloudflare_domain" {
  description = "Base domain for the cluster (e.g. opsbox.space)"
  type        = string
}