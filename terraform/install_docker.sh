#!/bin/bash
exec > /var/log/user-data.log 2>&1
set -x

# Install Docker
apt-get update -y
apt-get install -y docker.io

# Enable and start Docker
systemctl enable docker
systemctl start docker

# Add the 'admin' user to Docker group (if user exists)
usermod -aG docker admin || true

# Pull and run your container (IAM role provides AWS credentials)
docker pull ayush5626/ocr_web
docker run -d --name ocr \
  --network=host 
  -e S3_BUCKET=ocr-images-bucket-e6a2ac1e \
  -e S3_REGION=us-east-1 \
  -p 5000:5000 \
  ayush5626/ocr_web

docker start ocr
