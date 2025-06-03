# ========================================
# LOCALS
# ========================================
locals {
  s3_bucket_arn     = "arn:aws:s3:::${var.lambda_s3_bucket}"
  s3_bucket_objects = "arn:aws:s3:::${var.lambda_s3_bucket}/*"
  common_tags = {
    Project = "OCRApp"
    Env     = var.environment
  }
}

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

  tags = local.common_tags
}

resource "aws_iam_policy" "ocr_s3_policy" {
  name        = "ocr-s3-access-policy"
  description = "Allows EC2 to access S3 buckets and basic EC2/STS metadata"

  policy = jsonencode({
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
          local.s3_bucket_arn,
          local.s3_bucket_objects
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeInstances",
          "iam:GetInstanceProfile",
          "sts:GetCallerIdentity"
        ],
        Resource = "*"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "attach_s3_policy_to_ec2" {
  role       = aws_iam_role.ocr_ec2_role.name
  policy_arn = aws_iam_policy.ocr_s3_policy.arn
}

resource "aws_iam_instance_profile" "ocr_instance_profile" {
  name = "ocr-instance-profile"
  role = aws_iam_role.ocr_ec2_role.name

  tags = local.common_tags
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

  tags = local.common_tags
}

resource "aws_iam_policy" "ocr_lambda_policy" {
  name        = "ocr-lambda-access-policy"
  description = "Allows Lambda to read from S3, CloudWatch logs, and KMS for environment decryption"

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
          local.s3_bucket_arn,
          local.s3_bucket_objects
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
      },
      {
        Effect = "Allow",
        Action = [
          "kms:Decrypt"
        ],
        Resource = "*"  # Use specific KMS ARN if preferred
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "attach_lambda_policy" {
  role       = aws_iam_role.ocr_lambda_exec.name
  policy_arn = aws_iam_policy.ocr_lambda_policy.arn
}

# ========================================
# LAMBDA FUNCTION
# ========================================
resource "aws_lambda_function" "ocr_lambda" {
  count         = var.lambda_exists ? 0 : 1
  function_name = "ocr_lambda"
  role          = aws_iam_role.ocr_lambda_exec.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"

  s3_bucket = var.lambda_s3_bucket
  s3_key    = var.lambda_s3_key

  environment {
    variables = {
      APP_REGION = var.aws_region
    }
  }

  tags = local.common_tags
}

# ========================================
# LAMBDA PERMISSION: Allow S3 to invoke Lambda
# ========================================
resource "aws_lambda_permission" "allow_s3_to_invoke" {
  count         = var.lambda_exists ? 0 : 1
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ocr_lambda[0].function_name
  principal     = "s3.amazonaws.com"
  source_arn    = local.s3_bucket_arn
}

# ========================================
# S3 BUCKET NOTIFICATION -> Trigger Lambda
# ========================================
resource "aws_s3_bucket_notification" "ocr_lambda_trigger" {
  count  = var.lambda_exists ? 0 : 1
  bucket = var.lambda_s3_bucket

  lambda_function {
    id                  = "s3-to-lambda-ocr"
    lambda_function_arn = aws_lambda_function.ocr_lambda[0].arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "uploads/"
    filter_suffix       = ".jpg"
  }

  depends_on = [aws_lambda_permission.allow_s3_to_invoke]
}

# ========================================
# IAM POLICY FOR TERRAFORM USER TO MANAGE LAMBDA
# ========================================
resource "aws_iam_policy" "terraform_lambda_admin_policy" {
  name = "terraform-lambda-admin-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "LambdaFullAccess"
        Effect = "Allow"
        Action = [
          "lambda:CreateFunction",
          "lambda:UpdateFunctionCode",
          "lambda:GetFunction",
          "lambda:GetPolicy",
          "lambda:DeleteFunction",
          "lambda:ListVersionsByFunction",
          "lambda:GetFunctionCodeSigningConfig",
          "lambda:AddPermission",
          "lambda:RemovePermission",
          "lambda:InvokeFunction",
          "lambda:UpdateFunctionConfiguration"
        ]
        Resource = "*"
      },
      {
        Sid    = "IAMPassRole"
        Effect = "Allow"
        Action = ["iam:PassRole"]
        Resource = "*"
      },
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Sid    = "S3Access"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:GetBucketNotification",
          "s3:PutBucketNotification"
        ]
        Resource = "*"
      },
      {
        Sid    = "VPCIfNeeded"
        Effect = "Allow"
        Action = [
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs"
        ]
        Resource = "*"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_user_policy_attachment" "attach_lambda_admin_to_user" {
  user       = "terraform"
  policy_arn = aws_iam_policy.terraform_lambda_admin_policy.arn
}
