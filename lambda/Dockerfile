# lambda/Dockerfile

FROM amazonlinux:2

RUN yum -y update && \
    yum install -y \
        python3 python3-devel \
        gcc gcc-c++ make cmake \
        tesseract tesseract-langpack-eng \
        opencv opencv-devel \
        zlib-devel libjpeg-devel \
        zip && \
    yum clean all

RUN python3 -m pip install --upgrade pip

WORKDIR /opt/lambda

COPY requirements.txt .
RUN pip3 install -r requirements.txt -t python/

COPY lambda_function.py ocr_utils.py python/

# ✅ ZIP inside the Docker image itself
RUN cd python && zip -r9 /opt/lambda/ocr_lambda.zip .
