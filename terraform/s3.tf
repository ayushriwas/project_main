resource "random_id" "bucket_id" {
  byte_length = 4
}

resource "aws_s3_bucket" "ocr_bucket" {
  bucket        = "ocr-images-bucket-${random_id.bucket_id.hex}"
  force_destroy = true

  tags = {
    Name = "OCR Images Bucket"
  }
}
