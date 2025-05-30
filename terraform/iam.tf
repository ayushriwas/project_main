# IAM role for EC2
resource "aws_iam_role" "ocr_ec2_role" {
  name = "ocr-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# IAM policy for EC2 to access S3
resource "aws_iam_policy" "ocr_s3_policy" {
  name        = "ocr-s3-access-policy"
  description = "Allows EC2 to access S3 buckets"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket"
      ],
      Resource = [
        "arn:aws:s3:::ocr-images-bucket-*",
        "arn:aws:s3:::ocr-images-bucket-*/*"
      ]
    }]
  })
}

# Attach EC2 policy to role
resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.ocr_ec2_role.name
  policy_arn = aws_iam_policy.ocr_s3_policy.arn
}

# ✅ THIS IS CRUCIAL (used in `instance.tf`)
resource "aws_iam_instance_profile" "ocr_instance_profile" {
  name = "ocr-instance-profile"
  role = aws_iam_role.ocr_ec2_role.name
}
