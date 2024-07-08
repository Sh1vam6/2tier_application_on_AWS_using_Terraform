terraform {
  backend "s3" {
    bucket  = "terraform-2tier-architecture"
    key     = "2tier-architecture.tfstate"
    region  = "us-east-1"
    profile = "default"
  }
}
