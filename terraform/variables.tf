variable "aws_region" {
  default = "us-east-1"
}

data "aws_availability_zones" "available" {
  state = "available"
}

variable "ami_id" {
  description = "Ubuntu Server 24.04 LTS"
  type        = string
}

variable "instance_type" {
  default = "t3.medium"
}

variable "key_name" {
  type        = string
  description = "Имя SSH-ключа, загруженного в AWS"
}
