variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-central-1"
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "AZs and subnet indexes"
  type = map(object({
    public  = number
    private = number
  }))
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "ssh_key_name" {
  description = "Name of the SSH key in AWS"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to the private key file"
  type        = string
}

variable "allowed_ip_cidr" {
  description = "CIDR block allowed to access bastion"
  type        = string
}

variable "cloudflare_token" {
  description = "Cloudflare API token"
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID"
  type        = string
}

variable "cloudflare_domain" {
  description = "Base domain name"
  type        = string
}

variable "master_nodes" {
  description = "List of master nodes with private IPs"
  type = list(object({
    private_ip = string
  }))
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}