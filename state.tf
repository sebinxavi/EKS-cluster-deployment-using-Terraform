terraform {
  backend "s3" {
    bucket                  = var.bucket
    key                     = "eks/terraform.tfstate"
    region                  = var.region
    shared_credentials_file = "./.aws/credentials"
    profile = "profile1"
  }
}
