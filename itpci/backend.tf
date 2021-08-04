terraform {
    backend "s3" {
    bucket = "usb-tf-itpci-awsconnect-salesforce-package"
    key    = "awsconnect-salesforce-package/awsconnect-salesforce-package-itpci/terraform.tfstate"
    region = "us-east-1"
  }
 }