terraform {
  backend "s3" {
    bucket         = "fullstack-practice-tf-state-6755d67a"
    key            = "dev/fullstack-practice/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "fullstack-practice-tf-locks"
    encrypt        = true
    profile        = "terraform-practice"
  }
}