# Basic Policy deployment Example
## Description
This example define an AWS S3 bucket and use the module to build a bucket policy to :
- force encryption
- Deny access to the bucket for any AWS users except the one allowed.  

## Use the example
Follow these instruction to use this example :  
- Optionally edit the `basic-policy.tf`
- run `terraform init`
- then you can run `terraform plan` and `terraform apply`

Don't forget to run `terraform destroy` if you were just running tests.