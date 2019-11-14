# Basic Policy deployment Example
## Description
This example define an AWS S3 bucket and use the module to build a bucket policy to :
- force encryption
- Deny access to the bucket for any AWS users except the one used with terraform to deploy the s3 bucket.
- Deny administration access for any AWS users except the one used with terraform to deploy the s3 bucket.

## Content
[basic-policy.tf](basic-policy.tf)
```
# Get the current caller identity
data "aws_caller_identity" "current" {}

# Create the bucket policy
module "policy_basic" {
  source         = "JousP/s3-bucket-policy/aws"
  version        = "2.1.0"
  bucket_arn     = aws_s3_bucket.policy_basic.arn
  admin_users_id = [data.aws_caller_identity.current.user_id]
}

# Create the S3 bucket
resource "aws_s3_bucket" "policy_basic" {
  bucket = "terraform-aws-s3-bucket-policy-basic"
  acl    = "private"
}

resource "aws_s3_bucket_policy" "policy_basic" {
  bucket = aws_s3_bucket.policy_basic.id
  policy = module.policy_basic.policy
}
```
## Use the example
Follow these instruction to use this example :  
- Optionally edit the `basic-policy.tf`
- run `terraform init`
- then you can run `terraform plan` and `terraform apply`

Don't forget to run `terraform destroy` if you were just running tests.