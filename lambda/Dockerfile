# lambda/Dockerfile
FROM public.ecr.aws/lambda/python:3.11

# Install system dependencies for numpy, OpenCV, Tesseract
RUN yum -y update && \
    yum install -y \
        python3 python3-devel \
        gcc gcc-c++ make cmake \
        opencv opencv-devel \
        tesseract tesseract-langpack-eng \
        zlib-devel libjpeg-devel zip && \
    yum clean all

# Working dir for building
WORKDIR /opt/lambda

# Copy Python dependencies
COPY requirements.txt .

# Install all dependencies to /python (Lambda layer format)
RUN pip install --upgrade pip && \
    pip install -r requirements.txt -t python/

# Copy your Lambda source code
COPY lambda_function.py ocr_utils.py python/

# Package all into zip
WORKDIR /opt/lambda/python
RUN zip -r9 /opt/lambda/ocr_lambda.zip .
