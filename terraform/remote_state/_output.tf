output "bucket_name" {
  description = "The S3 bucket name for remote terraform state."
  value       = aws_s3_bucket.terraform_state.bucket
}

output "bucket_arn" {
  description = "The S3 bucket ARN for remote terraform state."
  value       = aws_s3_bucket.terraform_state.arn
}
