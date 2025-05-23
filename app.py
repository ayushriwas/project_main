from flask import Flask, request, render_template, jsonify
import cv2
import pytesseract
#import easyocr
import numpy as np
import os
from werkzeug.utils import secure_filename

app = Flask(__name__)
UPLOAD_FOLDER = 'static/uploads'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

#reader = easyocr.Reader(['en'])

def preprocess_image(image_path):
    image = cv2.imread(image_path)
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    blur = cv2.GaussianBlur(gray, (5, 5), 0)
    _, thresh = cv2.threshold(blur, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
    return thresh

def extract_text_tesseract(image):
    return pytesseract.image_to_string(image)

#def extract_text_easyocr(image):
#    results = reader.readtext(image, gpu==False)
#    return "\n".join([res[1] for res in results])

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

            tesseract_text = extract_text_tesseract(processed_image)
#            easyocr_text = extract_text_easyocr(filepath)

            web_image_path = os.path.join('static/uploads', filename).replace("\\", "/")

            return render_template('result.html', image_path=web_image_path,
                                   tesseract_text=tesseract_text) #easyocr_text=easyocr_text)
    return render_template('index.html')

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)



