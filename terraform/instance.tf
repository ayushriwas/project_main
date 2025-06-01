provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "ocr_server" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  associate_public_ip_address = true

  iam_instance_profile        = aws_iam_instance_profile.ocr_instance_profile.name
  vpc_security_group_ids      = [aws_security_group.ocr_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              exec > /var/log/user-data.log 2>&1
              set -x

              # Update and install Docker
              apt-get update -y
              apt-get install -y docker.io

              # Enable and start Docker
              systemctl enable docker
              systemctl start docker

              # Add default user to Docker group (Ubuntu AMI)
              usermod -aG docker ubuntu
	      usermod -aG docker admin	
              # Wait a few seconds to ensure Docker is ready
              sleep 10

              # Pull and run Docker container
              docker pull ${var.docker_image}
              docker run --name ocr -d -p 5000:5000 ${var.docker_image}
              EOF

  tags = {
    Name = "OCR-Server"
  }
}
