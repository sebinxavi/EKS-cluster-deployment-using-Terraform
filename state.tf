terraform {
  backend "s3" {
    bucket                  = "terraform-state-bucket-dev1"
    key                     = "eks/terraform.tfstate"
    region                  = "us-east-1"
    shared_credentials_file = "./.aws/credentials"
    profile = "profile1"
  }
}
