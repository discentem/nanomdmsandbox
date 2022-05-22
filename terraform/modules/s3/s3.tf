resource "aws_s3_bucket" "enrollment_bucket" {
  bucket = "${var.bucket_name}-enrollment-bucket"
}

resource "aws_s3_object" "enrollment_profile_obj" {
  bucket = aws_s3_bucket.enrollment_bucket.bucket
  key    = var.enrollment_profile_object_name
  source = var.enrollment_profile_source_path

  etag = filemd5("${var.enrollment_profile_source_path}")

  acl = "public-read"
}

resource "aws_s3_bucket_acl" "enrollment_endpoint_acl" {
  bucket = aws_s3_bucket.enrollment_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.enrollment_bucket.bucket

  index_document {
    suffix = "enrollment.mobileconfig"
  }
}