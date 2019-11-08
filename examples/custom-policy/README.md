# Custom Policy deployment Example
## Description
This example define an AWS S3 bucket, IAM users and roles and use the module to build a bucket policy to :
- force encryption on uploaded files
- Deny all access to the bucket for any AWS users not listed.
- Deny write access to the bucket for any user not listed in the `write_*` variables.  
- add a custom policy to allow the cloudwatch logs service tu push logs in the bucket.

## Use the example
Follow these instruction to use this example :  
- Optionally edit the `custom-policy.tf`
- run `terraform init`
- then you can run `terraform plan` and `terraform apply`

Don't forget to run `terraform destroy` if you were just running tests.