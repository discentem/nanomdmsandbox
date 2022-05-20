variable "bucket_name" {}
variable "enrollment_profile_object_name" {
  description = "Key in s3 referencing the enrollment.mobileconfig"
  type        = string
  default = "enrollment.mobileconfig"
}

variable "enrollment_profile_source_path" {
  description = "Local source for enrollment.mobileconfig"
  type        = string
}
