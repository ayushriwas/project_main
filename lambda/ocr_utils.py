# ocr_utils.py

from PIL import Image
import pytesseract
import io
import numpy as np
import cv2

def preprocess_image(image_bytes):
    image = Image.open(io.BytesIO(image_bytes)).convert("L")
    image_np = np.array(image)
    _, thresh = cv2.threshold(image_np, 150, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
    return Image.fromarray(thresh)

def perform_ocr(image_bytes):
    preprocessed = preprocess_image(image_bytes)
    text = pytesseract.image_to_string(preprocessed)
    return text
