provider "aws" {
  region = var.aws_region
}

resource "aws_lambda_function" "ocr_lambda" {
  function_name = "ocr_lambda"
  role          = aws_iam_role.ocr_lambda_exec.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"

  s3_bucket         = var.lambda_s3_bucket
  s3_key            = var.lambda_s3_key
  source_code_hash  = filebase64sha256("${path.module}/../lambda/build/ocr_lambda.zip")

  environment {
    variables = {
      AWS_DEFAULT_REGION = var.aws_region
    }
  }
}

# IAM Role for Lambda
resource "aws_iam_role" "ocr_lambda_exec" {
  name = "ocr-lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy for Lambda to access S3 and CloudWatch
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

# Attach IAM Policy to Lambda Role
resource "aws_iam_role_policy_attachment" "attach_lambda_policy" {
  role       = aws_iam_role.ocr_lambda_exec.name
  policy_arn = aws_iam_policy.ocr_lambda_policy.arn
}
