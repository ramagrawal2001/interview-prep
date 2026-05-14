resource "random_id" "bucket_suffix" {
  byte_length = 4
}

module "app_bucket" {
  source = "../../modules/s3-bucket"

  bucket_name  = "${var.project_name}-${var.environment}-${random_id.bucket_suffix.hex}"
  project_name = var.project_name
  environment  = var.environment
}
