## Get the bucket account information
data "aws_caller_identity" "bucket" {
  # add filter here
}

## Local variable to define permission
locals {
  read_principal = distinct(compact(var.access_principal))
  read_users     = distinct(compact(concat([data.aws_caller_identity.bucket.account_id], var.access_users, var.write_users)))
  read_roles     = distinct(formatlist("%s:*", compact(concat(var.access_roles, var.write_roles))))
  rw_users       = distinct(compact(concat([data.aws_caller_identity.bucket.account_id], var.write_users)))
  rw_roles       = distinct(formatlist("%s:*", compact(var.write_roles)))
}

## Local variable to format previous lists
locals {
  principal_json = join(", ", formatlist("\"%s\"", local.read_principal))
  read_json      = join(", ", formatlist("\"%s\"", concat(local.read_users, local.read_roles)))
  write_json     = join(", ", formatlist("\"%s\"", concat(local.rw_users, local.rw_roles)))
}

## Local variable to create the policy
locals {
  template_dir             = "${path.module}/templates"
  template_vars            = {
    encrypt                = var.force_encrypt
    bucket_arn             = var.bucket_arn
    read_principals        = local.principal_json
    authorized_read_users  = local.read_json
    authorized_write_users = local.write_json
    extra_statements       = var.extra_statements
  }
  policy                   = templatefile("${local.template_dir}/policy.tpl", local.template_vars)
}