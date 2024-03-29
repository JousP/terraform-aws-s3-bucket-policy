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

