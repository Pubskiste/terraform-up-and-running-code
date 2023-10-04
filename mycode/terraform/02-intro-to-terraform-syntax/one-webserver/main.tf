terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# The AWS provider block configures the AWS provider with the given region.
provider "aws" {
  region = "eu-central-1"
}

# The aws_instance resource creates and manages an EC2 instance.
# - instance_type: The type of EC2 instance to create.
# - availability_zone: The AZ in which to create the instance.
# - ami: The AMI ID to use for the instance.
# - vpc_security_group_ids: The security group IDs to associate with the instance.
# - user_data: The user data script to run on boot.
# - user_data_replace_on_change: Whether to replace the user data on every run.
# - tags: Tags to associate with the instance.
resource "aws_instance" "app" {
  instance_type          = "t2.micro"
  availability_zone      = "eu-central-1a"
  ami                    = "ami-0f81db4cf7eb125ce"
  vpc_security_group_ids = [aws_security_group.instance.id]
  subnet_id = data.aws_subnet.vpc_subnet1.id
  user_data              = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF
  user_data_replace_on_change = true
  tags = {
    Name = "terraform-example-01"
  }
}

# The aws_security_group resource defines a security group.
# - name: The name of the security group.
# - ingress: The ingress rules that define what traffic is allowed.
#   - from_port: The start port for the rule.
#   - to_port: The end port for the rule.
#   - protocol: The protocol for the rule.
#   - cidr_blocks: The CIDR blocks allowed access.
resource "aws_security_group" "instance" {
  name = "terraform-example-instance"
  vpc_id = data.aws_vpc.vpc.id
  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "vpc_id" {
  description = "Id of the VPC where the EC2-Instances get deployed to."
  type        = string
}

variable "aws_subnet_id" {
  description = "Subnet in which the EC2-Instance should be deployed."
  type        = string
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

output "public_ip" {
  value       = aws_instance.app.public_ip
  description = "The public IP address of the web server"
}