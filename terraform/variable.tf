variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

variable "ami_id" {
  description = "Amazon Machine Image ID"
  # Ubuntu 22.04 in us-east-1 (update for your region)
  default     = "ami-0c02fb55956c7d316"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "key_name" {
  description = "Key pair name for SSH access"
  type        = string
}

variable "docker_image" {
  description = "Docker image to run"
  type        = string
  default     = "ayush5626/ocr_web"
}

variable "vpc_id" {
  description = "The VPC ID for the security group"
  type        = vpc-03f5627c16d0f039a
}
