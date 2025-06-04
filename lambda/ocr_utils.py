import cv2
import pytesseract

def preprocess_image(image_path):
    try:
        image = cv2.imread(image_path)
        if image is None:
            raise ValueError(f"Unable to read image from path: {image_path}")
        print(f"[INFO] Loaded image from {image_path}")

        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        print("[INFO] Converted to grayscale")

        blur = cv2.GaussianBlur(gray, (5, 5), 0)
        print("[INFO] Applied Gaussian blur")

        _, thresh = cv2.threshold(blur, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
        print("[INFO] Applied Otsu thresholding")

        return thresh

    except Exception as e:
        raise RuntimeError(f"[ERROR] Image preprocessing failed: {e}")

def process_image_and_extract_text(image_path):
    try:
        pytesseract.pytesseract.tesseract_cmd = "/opt/bin/tesseract"  # ✅ Add this line for Lambda

        processed = preprocess_image(image_path)
        print("[INFO] Starting OCR extraction")

        text = pytesseract.image_to_string(processed)
        print("[INFO] OCR extraction completed")

        return text
    except Exception as e:
        raise RuntimeError(f"[ERROR] OCR processing failed: {e}")
