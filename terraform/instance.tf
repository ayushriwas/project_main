resource "aws_iam_role" "ocr_ec2_role" {
  name = "ocr-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "ocr_s3_policy" {
  name        = "ocr-s3-access-policy"
  description = "Allows EC2 to access S3 buckets"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::ocr-images-bucket-e6a2ac1e",
          "arn:aws:s3:::ocr-images-bucket-e6a2ac1e/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.ocr_ec2_role.name
  policy_arn = aws_iam_policy.ocr_s3_policy.arn
}

resource "aws_iam_instance_profile" "ocr_instance_profile" {
  name = "ocr-instance-profile"
  role = aws_iam_role.ocr_ec2_role.name
}

resource "aws_security_group" "ocr_sg" {
  name        = "ocr-security-group"
  description = "Allow HTTP access on port 5000"
  vpc_id      = var.vpc_id  # Optional: only if you're in a custom VPC

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ocr_server" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.ocr_instance_profile.name
  vpc_security_group_ids = [aws_security_group.ocr_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y docker.io
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
