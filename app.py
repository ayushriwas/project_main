from flask import Flask, request, jsonify
import boto3
import os
import uuid
from ocr_utils import process_image_and_extract_text

app = Flask(__name__)
s3 = boto3.client('s3')

UPLOAD_FOLDER = '/tmp'  # Lambda-compatible, also works locally
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

@app.route('/', methods=['GET'])
def home():
    return '''
    <h1>OCR Image Upload</h1>
    <form action="/upload" method="post" enctype="multipart/form-data">
        <input type="file" name="file" required>
        <input type="submit" value="Upload Image">
    </form>
    '''

@app.route('/upload', methods=['POST'])
def upload_image():
    file = request.files['file']

    # Save to a temporary file
    temp_filename = os.path.join(UPLOAD_FOLDER, f"{uuid.uuid4()}.jpg")
    file.save(temp_filename)

    try:
        text = process_image_and_extract_text(temp_filename)
        return jsonify({'ocr_text': text})
    finally:
        # Clean up temp file
        if os.path.exists(temp_filename):
            os.remove(temp_filename)

if __name__ == '__main__':
    app.run(debug=True, host="0.0.0.0", port=5000)
