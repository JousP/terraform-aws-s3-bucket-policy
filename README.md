# terraform-aws-s3-bucket-policy
A terraform module to help building policies for highly restricted S3 buckets

This module creates :
- a json formated string to be used to create an S3 bucket policy

This module can :  
- force uploaded data to be encrypted by checking the s3:x-amz-server-side-encryption variable in the s3:PutObject request and reject it if missing
- explicitly deny all unauthorized users and role at the bucket level even if they have an IAM policy allowing them to perform actions in S3
- explicitly deny all actions other than s3:list* and s3:Get* for readonly_users at the bucket level
- explicitly deny all administration access for non-admin users

