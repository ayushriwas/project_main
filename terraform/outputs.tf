output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.ocr_server.public_ip
}

output "app_url" {
  description = "App URL"
  value       = "http://${aws_instance.ocr_server.public_ip}:5000"
}

output "s3_bucket_name" {
  value = aws_s3_bucket.ocr_bucket.bucket
}
