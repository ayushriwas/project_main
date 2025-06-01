provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "ocr_server" {
  ami                         = "ami-0779caf41f9ba54f0"
  instance_type               = "t2.micro"
  key_name                    = "terraform"
  associate_public_ip_address = true

  iam_instance_profile        = aws_iam_instance_profile.ocr_instance_profile.name
  vpc_security_group_ids      = [aws_security_group.ocr_sg.id]

  user_data = <<-EOF
              #!/bin/bash

              # Update and install Docker
              sudo apt update 
              sudo apt install -y docker.io

              # Enable and start Docker
              sudo systemctl enable docker
              sudo systemctl start docker

              # Add default user to Docker group (Ubuntu AMI)
              sudo usermod -aG docker ubuntu
	      sudo usermod -aG docker admin	
              sudo systemctl restart docker 
	      # Wait a few seconds to ensure Docker is ready
              sleep 15

              # Pull and run Docker container
              docker pull ayush5626/ocr_web
              docker run --name ocr -d -p 5000:5000 ayush5626/ocr_web
              EOF

  tags = {
    Name = "OCR-Server"
  }
}
