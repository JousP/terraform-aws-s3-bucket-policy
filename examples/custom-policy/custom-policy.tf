# Get the current caller identity
data "aws_caller_identity" "current" {}

# Create IAM users
resource "aws_iam_user" "readonly" {
  name          = "readonly-user"
  force_destroy = true
}

resource "aws_iam_user" "rw" {
  name          = "readwrite-user"
  force_destroy = true
}

# Create IAM Roles
resource "aws_iam_role" "readonly" {
  name               = "readonly-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_role" "rw" {
  name               = "readwrite-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

# Create an extra statement
locals {
  extra_policy  = templatefile("./policies/cloudwatch.json.partial", local.template_vars)
  template_vars = {
    bucket_arn  = aws_s3_bucket.policy_custom.arn
    cloudwatch  = "logs.${var.aws_region}.amazonaws.com"
  }
}

# Create the bucket policy
module "policy_custom" {
  source             = "JousP/s3-bucket-policy/aws"
  version            = "2.1.0"
  bucket_arn         = aws_s3_bucket.policy_custom.arn
  admin_users_id     = [data.aws_caller_identity.current.user_id]
  readwrite_users_id = [aws_iam_user.rw.unique_id]
  readwrite_roles_id = [aws_iam_role.rw.unique_id]
  readonly_users_id  = [aws_iam_user.readonly.unique_id]
  readonly_roles_id  = [aws_iam_role.readonly.unique_id]
  readonly_arns      = ["arn:aws:iam::122324294275:user/awslogs.prod.eu-west-1.s3_export", "arn:aws:iam::122324294275:root"]
  extra_statements   = [local.extra_policy]
}

# Create the S3 bucket
resource "aws_s3_bucket" "policy_custom" {
  bucket = "terraform-aws-s3-bucket-policy-custom"
  acl    = "private"
}

resource "aws_s3_bucket_policy" "policy_custom" {
  bucket = aws_s3_bucket.policy_custom.id
  policy = module.policy_custom.policy
}
