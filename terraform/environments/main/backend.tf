terraform {
  backend "s3" {
    bucket  = "terraform-pra"
    #key     = "terraform-test423526/terraform.tfstate"
    region  = "ap-northeast-1"
  }
}