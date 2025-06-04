FROM public.ecr.aws/lambda/python:3.11

# Install OS-level dependencies
RUN yum install -y \
    zip \
    python3-devel \
    gcc gcc-c++ \
    cmake \
    opencv opencv-devel \
    tesseract \
    tesseract-langpack-eng \
    zlib-devel \
    libjpeg-devel && \
    yum clean all

# Upgrade pip
RUN pip install --upgrade pip

# Set up Lambda build folder
WORKDIR /opt/python

# Install Python dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt .

# Add your source files
COPY lambda_function.py /opt/
COPY ocr_utils.py /opt/

# Zip everything into the Lambda bundle
WORKDIR /opt
RUN mkdir -p /opt/lambda && zip -r /opt/lambda/ocr_lambda.zip .
