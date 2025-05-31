import cv2
import pytesseract
from PIL import Image
import numpy as np

def preprocess_image(image_path):
    """
    Preprocess the image for better OCR results.
    Steps:
    - Convert to grayscale
    - Apply Gaussian blur
    - Use adaptive thresholding
    """
    image = cv2.imread(image_path)

    if image is None:
        raise ValueError(f"Could not read image from {image_path}")

    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    blur = cv2.GaussianBlur(gray, (5, 5), 0)
    thresh = cv2.adaptiveThreshold(
        blur, 255, cv2.ADAPTIVE_THRESH_MEAN_C, cv2.THRESH_BINARY, 11, 2
    )
    return thresh

def process_image_and_extract_text(image_path):
    """
    Reads an image, applies preprocessing, and extracts text using Tesseract OCR.
    """
    preprocessed = preprocess_image(image_path)

    # Convert OpenCV image to PIL format
    pil_image = Image.fromarray(preprocessed)

    # Run Tesseract OCR
    text = pytesseract.image_to_string(pil_image)

    return text.strip()
