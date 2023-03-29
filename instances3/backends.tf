terraform {
  backend "s3" {
    bucket = "statefile-common-location-bucket"
    key = "statefile-key"
    region = "us-west-2"
    dynamodb_table = "statefile_lock" 
  }
}