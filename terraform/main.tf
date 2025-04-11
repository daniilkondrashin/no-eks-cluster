resource "aws_instance" "main" {
  count                       = 3
  ami                         = var.ami_id
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.main[count.index].id
  vpc_security_group_ids      = [aws_security_group.k8s.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "k8s-main-${count.index + 1}"
  }
}