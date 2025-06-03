# lambda/Dockerfile
FROM public.ecr.aws/lambda/python:3.11

# Install build dependencies and OpenCV
RUN yum -y update && \
    yum -y install gcc gcc-c++ cmake python3-devel \
                   opencv opencv-devel zlib-devel libjpeg-devel \
                   zip && \
    pip3 install --upgrade pip

WORKDIR /opt/lambda

# Copy requirements and source code
COPY requirements.txt .
RUN pip install -r requirements.txt -t python

COPY lambda_function.py ocr_utils.py python/

WORKDIR /opt/lambda/python
RUN zip -r9 /opt/lambda/ocr_lambda.zip .
