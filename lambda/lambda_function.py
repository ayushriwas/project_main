import os
import boto3
import tempfile
from ocr_utils import process_image_and_extract_text

def lambda_handler(event, context):
    # Extract bucket and object key from the S3 event
    try:
        bucket = event['Records'][0]['s3']['bucket']['name']
        key = event['Records'][0]['s3']['object']['key']
    except (KeyError, IndexError) as e:
        return {
            'statusCode': 400,
            'body': f"Invalid event structure: {str(e)}"
        }

    # Region fallback (optional override)
    region = os.getenv("APP_REGION", "us-east-1")

    s3 = boto3.client('s3', region_name=region)

    try:
        # Download image to temp file
        with tempfile.NamedTemporaryFile(suffix=".jpg") as temp_file:
            s3.download_file(bucket, key, temp_file.name)

            # Run OCR on the downloaded image
            extracted_text = process_image_and_extract_text(temp_file.name)

        # Log result (or integrate with downstream service)
        print(f"OCR result for {key}:\n{extracted_text}")

        return {
            'statusCode': 200,
            'body': f'OCR completed for {key}. Extracted text:\n{extracted_text}'
        }

    except Exception as e:
        print(f"Error processing file {key} from bucket {bucket}: {e}")
        return {
            'statusCode': 500,
            'body': f'Failed to process image: {str(e)}'
        }
