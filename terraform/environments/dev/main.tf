provider "aws" {
  region = var.aws_region
}

provider "cloudflare" {
  api_token = var.cloudflare_token
}

module "network" {
  source   = "../../modules/network"
  name     = "k8s"
  vpc_cidr = var.vpc_cidr
  azs      = var.availability_zones
  tags     = var.tags
}

module "bastion_lb" {
  source                = "../../modules/bastion-lb"
  ami_id                = var.ami_id
  instance_type         = "t3.micro"
  ssh_key_name          = var.ssh_key_name
  ssh_private_key_path  = var.ssh_private_key_path
  vpc_id                = module.network.vpc_id
  public_subnet_id      = module.network.public_subnets[0]
  private_subnet_ids    = module.network.private_subnets
  master_private_ips    = [for i in var.master_nodes : i.private_ip]
  allowed_ip_cidr       = var.allowed_ip_cidr
  enable_vpn            = true
  cloudflare_token      = var.cloudflare_token
  cloudflare_zone_id    = var.cloudflare_zone_id
  cloudflare_domain     = var.cloudflare_domain

  providers = {
    cloudflare = cloudflare
    aws        = aws
  }
}

locals {
  master_nodes = {
    for idx, node in var.master_nodes :
    "master-${idx + 1}" => {
      instance_type = "t3.medium"
      subnet_id     = module.network.private_subnets[idx]
      private_ip    = node.private_ip
      role          = "master"
    }
  }

  worker_nodes = {
    worker-1 = {
      instance_type = "t3.large"
      subnet_id     = module.network.private_subnets[0]
      private_ip = "10.0.160.20"
      role          = "worker"
    }
    worker-2 = {
      instance_type = "t3.large"
      subnet_id     = module.network.private_subnets[1]
      private_ip = "10.0.176.20"
      role          = "worker"
    }
  }

  all_nodes = merge(local.master_nodes, local.worker_nodes)
}

module "k8s_nodes" {
  source              = "../../modules/k8s-nodes"
  ami_id              = var.ami_id
  ssh_key_name        = var.ssh_key_name
  vpc_id              = module.network.vpc_id
  allowed_ip_cidr     = "10.6.0.0/24"
  cluster_cidr        = var.vpc_cidr
  default_tags        = var.tags
  nodes               = local.all_nodes
}
