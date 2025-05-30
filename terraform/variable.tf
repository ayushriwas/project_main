variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"
  type 	      = string
}

variable "ami_id" {
  description = "Amazon Machine Image ID"
  default     = "ami-04b70fa74e45c3917"  # Debian-based AMI
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
  default     = "ayush5626/ocr_web"
}

variable "vpc_id" {
  description = "VPC ID where the instance will be launched"
  type        = string
}
