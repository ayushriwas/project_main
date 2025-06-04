FROM public.ecr.aws/lambda/python:3.11

RUN pip install --upgrade pip

# Install zip utility
RUN yum install -y zip && yum clean all

# Install Python dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt -t /opt/python

# Copy Lambda source code
COPY lambda_function.py /opt/
COPY ocr_utils.py /opt/

# Create lambda output directory and zip
RUN mkdir -p /opt/lambda
WORKDIR /opt
RUN zip -r /opt/lambda/ocr_lambda.zip .
