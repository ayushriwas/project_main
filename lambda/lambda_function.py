import os
import boto3
import tempfile
from ocr_utils import process_image_and_extract_text

def lambda_handler(event, context):
    # Extract bucket and object key from the S3 event
    try:
        bucket = event['Records'][0]['s3']['bucket']['name']
        key = event['Records'][0]['s3']['object']['key']
        print(f"[INFO] Received file: s3://{bucket}/{key}")
    except (KeyError, IndexError) as e:
        print(f"[ERROR] Invalid event structure: {e}")
        return {
            'statusCode': 400,
            'body': f"Invalid event structure: {str(e)}"
        }

    # Use environment variable or fallback to default region
    region = os.getenv("APP_REGION", "us-east-1")
    s3 = boto3.client('s3', region_name=region)

    try:
        # Download image to temp file
        with tempfile.NamedTemporaryFile(suffix=".jpg") as temp_file:
            print(f"[INFO] Downloading image to {temp_file.name}")
            s3.download_file(bucket, key, temp_file.name)

            # Run OCR
            print(f"[INFO] Running OCR on {key}")
            extracted_text = process_image_and_extract_text(temp_file.name)
            print(f"[INFO] Extracted text: {extracted_text[:100]}...")  # Log first 100 chars

        # Define output key
        result_key = key.replace("uploads/", "results/").rsplit(".", 1)[0] + ".txt"

        # Upload result to S3
        print(f"[INFO] Uploading result to s3://{bucket}/{result_key}")
        s3.put_object(
            Bucket=bucket,
            Key=result_key,
            Body=extracted_text.encode('utf-8'),
            ContentType='text/plain'
        )

        return {
            'statusCode': 200,
            'body': f'OCR completed. Result uploaded to s3://{bucket}/{result_key}'
        }

    except Exception as e:
        print(f"[ERROR] Failed to process file: {e}")
        return {
            'statusCode': 500,
            'body': f'Error: {str(e)}'
        }
