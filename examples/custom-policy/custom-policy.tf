data "aws_caller_identity" "current" {}

# Create IAM users
resource "aws_iam_user" "readonly" {
  name = "readonly-user"
  force_destroy = true
}

resource "aws_iam_user" "rw" {
  name = "readwrite-user"
  force_destroy = true
}

# Create IAM Roles
resource "aws_iam_role" "readonly" {
  name = "readonly-role"
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
  name = "readwrite-role"
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
data "template_file" "extra_policy" {
  template     = "${file("./policies/cloudwatch.json.partial")}"
  vars {
    bucket_arn = "${aws_s3_bucket.policy_custom.arn}"
    cloudwatch = "logs.${var.aws_region}.amazonaws.com"
  }
}
# Create the bucket policy
module "policy_custom" {
  source           = "JousP/s3-bucket-policy/aws"
  version          = "1.0.0"
  bucket_arn       = "${aws_s3_bucket.policy_custom.arn}"
  write_users      = ["${aws_iam_user.rw.unique_id}", "${data.aws_caller_identity.current.user_id}"]
  write_roles      = ["${aws_iam_role.rw.unique_id}"]
  access_users     = ["${aws_iam_user.readonly.unique_id}"]
  access_roles     = ["${aws_iam_role.readonly.unique_id}"]
  access_principal = ["arn:aws:iam::122324294275:user/awslogs.prod.eu-west-1.s3_export", "arn:aws:iam::122324294275:root"]
  extra_statements = ["${data.template_file.extra_policy.rendered}"]
}

# Create the S3 bucket
resource "aws_s3_bucket" "policy_custom" {
  bucket = "terraform-aws-s3-bucket-policy-custom"
  acl    = "private"
}

resource "aws_s3_bucket_policy" "policy_custom" {
  bucket = "${aws_s3_bucket.policy_custom.id}"
  policy = "${module.policy_custom.policy}"
}