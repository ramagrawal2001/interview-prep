variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "environment" {
  description = "Environment name like dev, stage, or prod"
  type        = string
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
}