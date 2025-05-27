provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "ocr_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.ocr_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y docker.io
              sudo systemctl start docker
              sudo docker run -d -p 5000:5000 ${var.docker_image}
              EOF

  tags = {
    Name = "OCR-Server"
  }
}

resource "aws_security_group" "ocr_sg" {
  name        = "ocr-sg"
  description = "Allow SSH and web traffic"
  ingress = [
    {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "Web"
      from_port   = 5000
      to_port     = 5000
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  egress = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

