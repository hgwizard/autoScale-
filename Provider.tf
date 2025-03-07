provider "aws" {
  region = "us-east-1" # Change this to your desired region
}

resource "aws_s3_bucket" "class_bucket" {
  bucket = "Rob-hw" # Change to a globally unique name

  tags = {
    Name        = "rob-hw"
    Environment = "Jenkis"
  }
}

