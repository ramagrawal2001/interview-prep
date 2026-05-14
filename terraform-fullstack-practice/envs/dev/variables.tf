variable "aws_region" {
  description = "AWS region for dev resources"
  type        = string
}

variable "aws_profile" {
  description = "AWS CLI profile for Terraform"
  type        = string
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}