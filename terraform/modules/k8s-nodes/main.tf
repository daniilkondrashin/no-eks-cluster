resource "aws_instance" "k8s_node" {
  for_each = var.nodes

  ami           = var.ami_id
  instance_type = each.value.instance_type
  subnet_id     = each.value.subnet_id
  key_name      = var.ssh_key_name
  private_ip    = each.value.private_ip

  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.k8s_nodes.id]

  tags = merge({
    Name = each.key
    Role = each.value.role
  }, var.default_tags)
}

resource "aws_security_group" "k8s_nodes" {
  name   = "k8s-nodes-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ip_cidr]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.cluster_cidr]
  }

  ingress {
  from_port   = -1
  to_port     = -1
  protocol    = "icmp"
  cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = [var.cluster_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}