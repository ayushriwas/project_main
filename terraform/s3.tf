resource "random_id" "bucket_id" {
  byte_length = 4
}

resource "aws_s3_bucket" "ocr_bucket" {
  bucket        = "ocr-images-bucket-e6a2ac1e"
  force_destroy = true

  tags = {
    Name = "OCR Images Bucket"
  }
}
