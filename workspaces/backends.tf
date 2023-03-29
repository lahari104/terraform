terraform {
  backend "s3" {
    bucket = "statefile-bucket-29th-march2023"
    key = "sample-statefile-key"
    region = "us-west-2"
    dynamodb_table = "statefile-lock" 
  }
}