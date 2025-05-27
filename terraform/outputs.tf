output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.ocr_server.public_ip
}

output "app_url" {
  description = "App URL"
  value       = "http://${aws_instance.ocr_server.public_ip}:5000"
}
