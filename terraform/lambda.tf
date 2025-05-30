resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_exec" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "ocr_lambda" {
  function_name = "ocr_lambda"
  role          = aws_iam_role.ocr_lambda_exec.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"

  filename         = "${path.module}/../lambda/ocr_lambda.zip"
  source_code_hash = filebase64sha256("${path.module}/../lambda/ocr_lambda.zip")

  environment {
    variables = {
      AWS_DEFAULT_REGION = var.aws_region
    }
  }
}

resource "aws_s3_bucket_notification" "lambda_trigger" {
  bucket = aws_s3_bucket.ocr_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.ocr_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "uploads/"
  }

  depends_on = [aws_lambda_permission.allow_s3]
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ocr_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.ocr_bucket.arn
}
