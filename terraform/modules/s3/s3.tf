resource "aws_s3_bucket" "enrollment_endpoint" {
  bucket = "${var.app_name}-enrollment_endpoint}"
}

resource "aws_s3_object" "enrollment_profile_obj" {
  bucket = aws_s3_bucket.enrollment_endpoint.bucket
  key    = var.enrollment_profile_object_name
  source = var.enrollment_profile_source_path

  etag = filemd5("${var.enrollment_profile_source_path}")
}

resource "aws_s3_bucket_acl" "enrollment_endpoint_acl" {
  bucket = aws_s3_bucket.enrollment_endpoint.id
  acl    = "private"
}

# resource "aws_s3_bucket_website_configuration" "example" {
#   bucket = aws_s3_bucket.enrollment_endpoint.bucket

#   index_document {
#     suffix = "enrollment.mobileconfig"
#   }
# }