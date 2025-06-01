#!/bin/bash
              exec > /var/log/user-data.log 2>&1
              set -x

              # Update and install Docker
              apt-get update -y
              apt-get install -y docker.io

              # Enable and start Docker
              systemctl enable docker
              systemctl start docker

              # Add the 'admin' user to the Docker group (if needed)
              usermod -aG docker admin || true

              # Wait a bit for Docker to be ready
              sleep 10

              # Pull and run the Docker container
              docker pull ayush5626/ocr_web
	      docker run --rm \
              -e S3_BUCKET=ocr-images-bucket-e6a2ac1e \
              -e S3_REGION=us-east-1 \
              ayush5626/ocr-web
