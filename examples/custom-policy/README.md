# Custom Policy deployment Example
## Description
This example define an AWS S3 bucket, IAM users and roles and use the module to build a bucket policy to :
- Force uploaded data to be encrypted by checking the s3:x-amz-server-side-encryption variable in the s3:PutObject request and reject it if missing
- Deny all unauthorized users, roles or arna at the bucket level even if they have an IAM policy allowing them to perform actions in S3.
- Deny all actions other than s3:list* and s3:Get* for the `readonly` users, roles and ARNs set in the `readonly_*` variables at the bucket level.
- Deny administration access for any AWS users except the one used with terraform to deploy the s3 bucket.
- Add a custom policy to allow the cloudwatch logs service tu push logs in the bucket.

## Content
[custom-policy.tf](custom-policy.tf)
```
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
```
## Use the example
Follow these instruction to use this example :  
- Optionally edit the `custom-policy.tf`
- run `terraform init`
- then you can run `terraform plan` and `terraform apply`

Don't forget to run `terraform destroy` if you were just running tests.