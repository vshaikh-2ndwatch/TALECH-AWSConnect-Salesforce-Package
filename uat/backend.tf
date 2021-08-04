terraform {
    backend "s3" {
    bucket = "usb-tf-uat-awsconnect-salesforce-package"
    key    = "awsconnect-salesforce-package/awsconnect-salesforce-package-uat/terraform.tfstate"
    region = "us-east-1"
  }
 }