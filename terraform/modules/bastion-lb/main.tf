resource "aws_instance" "bastion" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_id
  key_name                    = var.ssh_key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.bastion.id]

  user_data = var.enable_vpn ? file("${path.module}/scripts/wireguard-userdata.sh") : null

  tags = {
    Name = "bastion"
  }

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }
}

resource "aws_security_group" "bastion" {
  name   = "bastion-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ip_cidr]
  }

  ingress {
    from_port   = 51820
    to_port     = 51820
    protocol    = "udp"
    cidr_blocks = var.enable_vpn ? [var.allowed_ip_cidr] : []
  }

  ingress {
  from_port   = -1
  to_port     = -1
  protocol    = "icmp"
  cidr_blocks = ["10.0.0.0/16", "10.6.0.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "k8s_api" {
  name               = "k8s-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.private_subnet_ids
}

resource "aws_lb_target_group" "k8s_api" {
  name        = "k8s-api-tg"
  port        = 6443
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.vpc_id
}

resource "aws_lb_listener" "k8s_api" {
  load_balancer_arn = aws_lb.k8s_api.arn
  port              = 6443
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.k8s_api.arn
  }
}

resource "aws_lb_target_group_attachment" "masters" {
  for_each = toset(var.master_private_ips)

  target_group_arn = aws_lb_target_group.k8s_api.arn
  target_id        = each.key
  port             = 6443
}

resource "cloudflare_record" "k8s_api" {
  zone_id = var.cloudflare_zone_id
  name    = "k8s"
  type    = "CNAME"
  content = aws_lb.k8s_api.dns_name
  proxied = false
}