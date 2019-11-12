{
    "Version": "2012-10-17",
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
            %{ if read_principals == "" ~}
            "Principal": "*",
            %{ else ~}
            "NotPrincipal": {
                "AWS": [
                    ${read_principals}
                ]
            },
            %{ endif ~}
            "Action": "*",
            "Resource": [
                "${bucket_arn}",
                "${bucket_arn}/*"
            ],
            "Condition": {
                "StringNotLike": {
                    "aws:userId": [
                        ${authorized_read_users}
                    ]
                }
            }
        },
        {
            "Sid": "Deny any action other than Get/List for anyone not listed here",
            "Effect": "Deny",
            "Principal": {
                "AWS": "*"
            },
            "NotAction": [
                "s3:Get*",
                "s3:List*"
            ],
            "Resource": [
                "${bucket_arn}",
                "${bucket_arn}/*"
            ],
            "Condition": {
                "StringNotLike": {
                    "aws:userId": [
                        ${authorized_write_users}
                    ]
                }
            }
        }
        %{for statement in extra_statements ~}
        ,${statement}
        %{ endfor ~}
    ]
}
