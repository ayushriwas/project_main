# lambda_function.py

import boto3
from ocr_utils import perform_ocr

def lambda_handler(event, context):
    s3 = boto3.client('s3')

    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']

        response = s3.get_object(Bucket=bucket, Key=key)
        image_bytes = response['Body'].read()

        text = perform_ocr(image_bytes)

        # Optional: Save OCR result to S3
        result_key = key.rsplit('.', 1)[0] + '.txt'
        s3.put_object(Bucket=bucket, Key=f'ocr-results/{result_key}', Body=text)

    return {'statusCode': 200, 'body': 'OCR processed successfully'}
