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
              apt-get update -y
              apt-get install -y docker.io
              systemctl enable docker
              systemctl start docker
              docker pull ${var.docker_image}
              docker run -d -p 5000:5000 \
                -e AWS_DEFAULT_REGION=${var.aws_region} \
                ${var.docker_image}
              EOF

  tags = {
    Name = "OCR-Server"
  }
}
