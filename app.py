from flask import Flask, request, render_template
import cv2
import pytesseract
import numpy as np
import os
import boto3
import boto3
import os

s3 = boto3.client(
    's3',
    aws_access_key_id=os.getenv('AWS_ACCESS_KEY_ID'),
    aws_secret_access_key=os.getenv('AWS_SECRET_ACCESS_KEY'),
    region_name=os.getenv('AWS_DEFAULT_REGION')
)

from werkzeug.utils import secure_filename
from io import BytesIO
from PIL import Image

app = Flask(__name__)

# === AWS S3 CONFIGURATION ===
S3_BUCKET = 'ocr-images-bucket-xyz1234'  # replace with actual name after Terraform apply
S3_REGION = 'us-east-1'
s3 = boto3.client('s3', region_name=S3_REGION)

UPLOAD_FOLDER = 'static/uploads'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

def preprocess_image(image_path):
    image = cv2.imread(image_path)
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    blur = cv2.GaussianBlur(gray, (5, 5), 0)
    _, thresh = cv2.threshold(blur, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
    return thresh

def extract_text_tesseract(image):
    return pytesseract.image_to_string(image)

@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        file = request.files['image']
        if file:
            filename = secure_filename(file.filename)
            filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
            file.save(filepath)

            processed_image = preprocess_image(filepath)
            cv2.imwrite(filepath, processed_image)

            # Upload to S3
            with open(filepath, "rb") as img_data:
                s3.upload_fileobj(
                    img_data,
                    S3_BUCKET,
                    f"uploads/{filename}",
                    ExtraArgs={'ContentType': 'image/jpeg'}
                )

            # Generate S3 public URL
            image_url = f"https://{S3_BUCKET}.s3.{S3_REGION}.amazonaws.com/uploads/{filename}"

            # Extract text
            tesseract_text = extract_text_tesseract(processed_image)

            return render_template('result.html', image_path=image_url, tesseract_text=tesseract_text)
    return render_template('index.html')

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
