# app.py

from flask import Flask, request, jsonify
import boto3
from ocr_utils import perform_ocr

app = Flask(__name__)
s3 = boto3.client('s3')

@app.route('/upload', methods=['POST'])
def upload_image():
    file = request.files['file']
    image_bytes = file.read()

    text = perform_ocr(image_bytes)
    return jsonify({'ocr_text': text})

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
