variable "ami_id" {
  description = "AMI ID for the Kubernetes nodes"
  type        = string
}

variable "ssh_key_name" {
  description = "SSH key name for accessing the nodes"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the nodes will be deployed"
  type        = string
}

variable "allowed_ip_cidr" {
  description = "CIDR block allowed to SSH into nodes"
  type        = string
}

variable "cluster_cidr" {
  description = "CIDR block for internal Kubernetes communication"
  type        = string
  default     = "10.0.0.0/16"
}

variable "default_tags" {
  description = "Common tags applied to all nodes"
  type        = map(string)
  default     = {}
}

variable "nodes" {
  description = "Map of nodes to create"
  type = map(object({
    instance_type = string
    subnet_id     = string
    private_ip    = string
    role          = string
  }))
}