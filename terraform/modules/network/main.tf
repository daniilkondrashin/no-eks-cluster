resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge({
    Name = var.name
  }, var.tags)
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge({
    Name = "${var.name}-igw"
  }, var.tags)
}

resource "aws_subnet" "public" {
  for_each = var.azs

  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, each.value.public)
  availability_zone       = each.key
  map_public_ip_on_launch = true

  tags = merge({
    Name = "${var.name}-public-${each.key}"
  }, var.tags)
}

resource "aws_subnet" "private" {
  for_each = var.azs

  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, each.value.private)
  availability_zone = each.key

  tags = merge({
    Name = "${var.name}-private-${each.key}"
  }, var.tags)
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge({
    Name = "${var.name}-public-rt"
  }, var.tags)
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}