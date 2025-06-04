# lambda/Dockerfile
FROM public.ecr.aws/lambda/python:3.11

# ✅ Install Tesseract and OpenCV dependencies
RUN yum -y update && \
    yum -y install \
        gcc gcc-c++ cmake python3-devel \
        opencv opencv-devel \
        zlib-devel libjpeg-devel \
        zip \
        epel-release && \
    yum -y install tesseract tesseract-langpack-eng && \
    yum clean all

# Set working directory
WORKDIR /opt/lambda

# ✅ Copy Python dependencies
COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install -r requirements.txt -t python

# ✅ Copy source code
COPY lambda_function.py ocr_utils.py python/

# ✅ Package everything into a zip
WORKDIR /opt/lambda/python
RUN zip -r9 /opt/lambda/ocr_lambda.zip .
