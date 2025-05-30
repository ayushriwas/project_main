import os
import boto3
import tempfile
from ocr_utils import process_image_and_extract_text

def lambda_handler(event, context):
    # Get bucket and key from the S3 event
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']

    # Use custom environment variable (not reserved one)
    region = os.getenv("APP_REGION", "us-east-1")

    # Initialize S3 client
    s3 = boto3.client('s3', region_name=region)

    try:
        # Download the image from S3 to a temp file
        with tempfile.NamedTemporaryFile() as tmp_file:
            s3.download_file(bucket, key, tmp_file.name)

            # Run OCR on the image using shared utils
            extracted_text = process_image_and_extract_text(tmp_file.name)

        # Optionally log or return the result
        print(f"OCR result for {key}:\n{extracted_text}")
        return {
            'statusCode': 200,
            'body': f'Text extracted successfully from {key}.'
        }

    except Exception as e:
        print(f"Error processing file {key} from bucket {bucket}: {e}")
        return {
            'statusCode': 500,
            'body': f'Error processing image: {str(e)}'
        }
