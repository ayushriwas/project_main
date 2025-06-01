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

  user_data                   = file("${path.module}/install_docker.sh")

  tags = {
    Name = "OCR-Server"
  }
}
