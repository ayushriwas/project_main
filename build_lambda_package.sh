#!/bin/bash

set -e

# Define build variables
LAMBDA_DIR="lambda"
BUILD_DIR="$LAMBDA_DIR/build"
ZIP_NAME="ocr_lambda.zip"
IMAGE_NAME="lambda-builder"

echo "🚧 Cleaning previous build..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

echo "🐳 Building Docker image..."
docker build -f "$LAMBDA_DIR/Dockerfile.lambda-builder" -t "$IMAGE_NAME" "$LAMBDA_DIR"

echo "📦 Copying built zip from container..."
docker run --rm \
  --entrypoint /bin/sh \
  -v "$PWD/$BUILD_DIR:/output" \
  "$IMAGE_NAME" -c "cp /opt/lambda/ocr_lambda.zip /output/$ZIP_NAME"

echo "✅ Lambda deployment package built: $BUILD_DIR/$ZIP_NAME"
