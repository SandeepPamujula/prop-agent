# Note: S3 bucket and DynamoDB table should be created prior to applying with S3 backend.
# To test locally without S3 bucket, comment out this block or initialize with -backend=false.

terraform {
  backend "s3" {
    bucket         = "prop-agent-tfstate"
    key            = "dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "prop-agent-tfstate-lock"
    encrypt        = true
  }
}
