## Get the bucket account information
data "aws_caller_identity" "bucket" {
  # add filter here
}

## Local variable to define permission
locals {
  readonly_arn    = distinct(compact(var.readonly_arns))
  readonly_users  = distinct(compact(var.readonly_users_id))
  readonly_roles  = distinct(formatlist("%s:*", compact(var.readonly_roles_id)))
  readwrite_arn   = distinct(compact(var.readwrite_arn))
  readwrite_users = distinct(compact(var.readwrite_users_id))
  readwrite_roles = distinct(formatlist("%s:*", compact(var.readwrite_roles_id)))
  admin_users     = distinct(compact(concat([data.aws_caller_identity.bucket.account_id], var.admin_users_id)))
  admin_roles     = distinct(formatlist("%s:*", compact(var.admin_roles_id)))
}

## Local variable to create the policy
locals {
  template_dir       = "${path.module}/templates"
  template_vars      = {
    encrypt          = var.force_encrypt
    bucket_arn       = var.bucket_arn
    arns             = join(", ", formatlist("\"%s\"", distinct(concat(local.readwrite_arn, local.readonly_arn))))
    readonly_arns    = join(", ", formatlist("\"%s\"", local.readonly_arn))
    readwrite_arns   = join(", ", formatlist("\"%s\"", local.readwrite_arn))
    ids              = join(", ", formatlist("\"%s\"", distinct(concat(local.admin_users, local.admin_roles, local.readwrite_users, local.readwrite_roles, local.readonly_users, local.readonly_roles))))
    readonly_ids     = join(", ", formatlist("\"%s\"", concat(local.readonly_users, local.readonly_roles)))
    readwrite_ids    = join(", ", formatlist("\"%s\"", concat(local.readwrite_users, local.readwrite_roles)))
    admin_ids        = join(", ", formatlist("\"%s\"", concat(local.admin_users, local.admin_roles)))
    extra_statements = var.extra_statements
  }
  policy             = templatefile("${local.template_dir}/policy.tpl", local.template_vars)
}
