terraform {
  backend "s3" {
    bucket                  = "terraform-state-bucket11"
    key                     = "eks/terraform.tfstate"
    region                  = "us-east-1"
    shared_credentials_file = "./.aws/credentials"
    profile = "profile1"
  }
}
