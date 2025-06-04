FROM public.ecr.aws/lambda/python:3.11

# Install Tesseract and OpenCV + build dependencies
RUN yum -y update && \
    yum install -y epel-release && \
    yum install -y \
        python3 python3-devel \
        gcc gcc-c++ make cmake \
        tesseract tesseract-langpack-eng \
        opencv opencv-devel \
        zlib-devel libjpeg-devel \
        zip && \
    yum clean all

# Set working directory
WORKDIR /opt/lambda

# Install Python dependencies
COPY requirements.txt .
RUN pip install --upgrade pip && \
    pip install -r requirements.txt -t python/

# Copy your source code
COPY lambda_function.py ocr_utils.py python/

# Build the deployment package
RUN cd python && zip -r9 /opt/lambda/ocr_lambda.zip .
