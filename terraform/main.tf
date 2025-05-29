provider "aws" {
  region = var.aws_region
}

resource "aws_security_group" "ocr_sg" {
  name        = "ocr_sg"
  description = "Allow SSH and web traffic"
  vpc_id      = var.vpc_id  # Replace or remove if not using VPC

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }

  tags = {
    Name = "ocr-sg"
  }
}
