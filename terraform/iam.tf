# ========================================
# IAM ROLE AND POLICIES FOR EC2
# ========================================
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

resource "aws_iam_role_policy_attachment" "attach_s3_policy_to_ec2" {
  role       = aws_iam_role.ocr_ec2_role.name
  policy_arn = aws_iam_policy.ocr_s3_policy.arn
}

resource "aws_iam_instance_profile" "ocr_instance_profile" {
  name = "ocr-instance-profile"
  role = aws_iam_role.ocr_ec2_role.name
}

# ========================================
# IAM ROLE AND POLICIES FOR LAMBDA
# ========================================
resource "aws_iam_role" "ocr_lambda_exec" {
  name = "ocr-lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "ocr_lambda_policy" {
  name        = "ocr-lambda-access-policy"
  description = "Allows Lambda to read from S3 and write to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::ocr-images-bucket-*",
          "arn:aws:s3:::ocr-images-bucket-*/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_lambda_policy" {
  role       = aws_iam_role.ocr_lambda_exec.name
  policy_arn = aws_iam_policy.ocr_lambda_policy.arn
}

# ========================================
# LAMBDA FUNCTION
# ========================================
resource "aws_lambda_function" "ocr_lambda" {
  function_name = "ocr_lambda"
  role          = aws_iam_role.ocr_lambda_exec.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"

  s3_bucket = var.lambda_s3_bucket
  s3_key    = var.lambda_s3_key

  # REMOVE or comment this line if the file doesn't exist locally
  # source_code_hash = filebase64sha256("${path.module}/../lambda/build/ocr_lambda.zip")

  environment {
    variables = {
     APP_REGION  = var.aws_region
    }
  }
}

# ========================================
# IAM POLICY FOR TERRAFORM USER TO MANAGE LAMBDA
# ========================================
resource "aws_iam_policy" "terraform_lambda_admin_policy" {
  name = "terraform-lambda-admin-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "lambda:CreateFunction",
        "lambda:UpdateFunctionCode",
        "lambda:GetFunction",
        "lambda:DeleteFunction",
        "lambda:ListVersionsByFunction",
        "lambda:GetFunctionCodeSigningConfig",
        "iam:PassRole",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      Resource = "*"
    }]
  })
}

resource "aws_iam_user_policy_attachment" "attach_lambda_admin_to_user" {
  user       = "terraform"
  policy_arn = aws_iam_policy.terraform_lambda_admin_policy.arn
}
