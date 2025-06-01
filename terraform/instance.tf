provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "ocr_server" {
  ami                         = var.ami_id # e.g. "ami-xxxxxxxx"
  instance_type               = var.instance_type # e.g. "t2.micro"
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

              # Add the 'admin' user to the Docker group (if needed)
              usermod -aG docker admin || true

              # Wait a bit for Docker to be ready
              sleep 10

              # Pull and run the Docker container
              docker pull ayush5626/ocr_web
              docker run --name ocr -d -p 5000:5000 ayush5626/ocr_web
              EOF

  tags = {
    Name = "OCR-Server"
  }
}
