{
    "Version": "2012-10-17",
    "Id": "DenyNonExplicitAccess",
    "Statement": [
%{ if encrypt ~}
        {
            "Sid": "DenyIncorrectEncryptionHeader",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:PutObject",
            "Resource": "${bucket_arn}/*",
            "Condition": {
                "StringNotEquals": {
                    "s3:x-amz-server-side-encryption": "AES256"
                }
            }
        },
        {
            "Sid": "DenyUnEncryptedObjectUploads",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:PutObject",
            "Resource": "${bucket_arn}/*",
            "Condition": {
                "Null": {
                    "s3:x-amz-server-side-encryption": "true"
                }
            }
        },
%{ endif ~}
        {
            "Sid": "Deny all access for anyone not listed here",
            "Effect": "Deny",
%{ if length(arns) > 0 ~}
            "NotPrincipal": {
                "AWS": [
                    ${arns}
                ]
            },
%{ else ~}
            "Principal": "*",
%{ endif ~}
            "Action": "*",
            "Resource": [
                "${bucket_arn}",
                "${bucket_arn}/*"
            ],
            "Condition": {
                "StringNotLike": {
                    "aws:userId": [
                        ${ids}
                    ]
                }
            }
        }
%{ if length(readonly_ids) > 0 ~}
        ,{
            "Sid": "Deny any action other than Get/List for readonly users and roles",
            "Effect": "Deny",
            "Principal": "*",
            "NotAction": [
                "s3:Get*",
                "s3:List*"
            ],
            "Resource": [
                "${bucket_arn}",
                "${bucket_arn}/*"
            ],
            "Condition": {
                "StringLike": {
                    "aws:userId": [
                        ${readonly_ids}
                    ]
                }
            }
        }
%{ endif ~}
%{ if length(readonly_arns) > 0 ~}
        ,{
            "Sid": "Deny any action other than Get/List for readonly arns",
            "Effect": "Deny",
            "Principal": {
                "AWS": [
                    ${readonly_arns}
                ]
            },
            "NotAction": [
                "s3:Get*",
                "s3:List*"
            ],
            "Resource": [
                "${bucket_arn}",
                "${bucket_arn}/*"
            ]
        }
%{ endif ~}
%{ if length(admin_ids) > 0 ~}
        ,{
            "Sid": "Deny administration access for non admin users and roles",
            "Effect": "Deny",
            "Principal": "*",
            "Action": [
                "s3:DeleteObjectTagging",
                "s3:PutBucketPublicAccessBlock",
                "s3:ReplicateTags",
                "s3:PutObjectVersionTagging",
                "s3:DeleteObjectVersionTagging",
                "s3:DeleteBucketPolicy",
                "s3:ObjectOwnerOverrideToBucketOwner",
                "s3:PutBucketTagging",
                "s3:PutObjectVersionAcl",
                "s3:PutBucketAcl",
                "s3:PutBucketPolicy",
                "s3:PutObjectTagging",
                "s3:PutObjectAcl"
            ],
            "Resource": [
                "${bucket_arn}",
                "${bucket_arn}/*"
            ],
            "Condition": {
                "StringNotLike": {
                    "aws:userId": [
                        ${admin_ids}
                    ]
                }
            }
        }
%{ endif ~}
%{for statement in extra_statements ~}
,${statement}
%{ endfor ~}
    ]
}
