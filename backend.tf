terraform {
  backend "s3" {
    bucket = "mybucket"
    key    = "path/terraform-aws-centralised-logs/terraform.tfstate"
    region = "eu-west-1"
  }
}
