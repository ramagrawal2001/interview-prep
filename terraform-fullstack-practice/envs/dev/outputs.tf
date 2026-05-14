output "frontend_website_url" {
  description = "S3 static website URL"
  value       = "http://${aws_s3_bucket_website_configuration.frontend.website_endpoint}"
}

output "frontend_bucket_name" {
  description = "Frontend S3 bucket name"
  value       = aws_s3_bucket.frontend.bucket
}

output "backend_public_ip" {
  description = "Backend EC2 public IP"
  value       = aws_instance.backend.public_ip
}

output "backend_url" {
  description = "Backend API URL"
  value       = "http://${aws_instance.backend.public_ip}:3000"
}