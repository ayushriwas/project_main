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
              exec > /var/log/user-data.log 2>&1
              set -x

              # Update package list and install Docker
              apt-get update -y
              apt-get install -y docker.io

              # Enable and start Docker
              systemctl enable docker
              systemctl start docker

              # Add the 'admin' user to Docker group
              usermod -aG docker admin

              # Restart Docker to ensure group change takes effect
              systemctl restart docker

              # Wait for Docker to become ready
              sleep 15

              # Pull and run your Docker container
              docker pull ayush5626/ocr_web
              docker run --name ocr -d -p 5000:5000 ayush5626/ocr_web
EOF

  tags = {
    Name = "OCR-Server"
  }
}
