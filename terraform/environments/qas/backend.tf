terraform {
  backend "s3" {
    bucket  = "terraform-pra"
    key     = "terraform-pra/terraform.tfstate"
    region  = "ap-northeast-1"
  }
}