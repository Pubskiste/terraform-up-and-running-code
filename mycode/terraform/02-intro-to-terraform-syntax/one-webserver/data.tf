data "aws_vpc" "vpc" {
  id = var.vpc_id
}

data "aws_subnet" "vpc_subnet1" {
  id = var.aws_subnet_id
}