resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}