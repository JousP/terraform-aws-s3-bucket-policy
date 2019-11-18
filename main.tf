## Get the bucket account information
data "aws_caller_identity" "bucket" {}

## Local variable to define permission
locals {
  readonly_arn    = ["${distinct(compact(var.readonly_arns))}"]
  readonly_users  = ["${distinct(compact(var.readonly_users_id))}"]
  readonly_roles  = ["${distinct(formatlist("%s:*", compact(var.readonly_roles_id)))}"]
  readwrite_arn   = ["${distinct(compact(var.readwrite_arn))}"]
  readwrite_users = ["${distinct(compact(var.readwrite_users_id))}"]
  readwrite_roles = ["${distinct(formatlist("%s:*", compact(var.readwrite_roles_id)))}"]
  admin_users     = ["${distinct(compact(concat(list(data.aws_caller_identity.bucket.account_id), var.admin_users_id)))}"]
  admin_roles     = ["${distinct(formatlist("%s:*", compact(var.admin_roles_id)))}"]
}

## Local variable to create the policy
locals {
  template_dir       = "${path.module}/templates"
  template_vars      = {
    admin_ids        = "${join(", ", formatlist("\"%s\"", concat(local.admin_users, local.admin_roles)))}"
    arns             = "${join(", ", formatlist("\"%s\"", distinct(concat(local.readwrite_arn, local.readonly_arn))))}"
    bucket_arn       = "${var.bucket_arn}"
    ids              = "${join(", ", formatlist("\"%s\"", distinct(concat(local.admin_users, local.admin_roles, local.readwrite_users, local.readwrite_roles, local.readonly_users, local.readonly_roles))))}"
    readonly_arns    = "${join(", ", formatlist("\"%s\"", local.readonly_arn))}"
    readonly_ids     = "${join(", ", formatlist("\"%s\"", concat(local.readonly_users, local.readonly_roles)))}"
  }
}

## Build the "Force encrypt" Part of the policy
data "template_file" "encrypt" {
  template = "${var.force_encrypt ? file("${local.template_dir}/statement_force-encrypt.json.partial") : ""}"
  vars     = "${local.template_vars}"
}

## Build the "Principal" Part of the Policy
data "template_file" "principal" {
  template = "${file("${local.template_dir}/${local.template_vars["readonly_arns"] == "" ? "principal" : "not-principal"}.json.partial")}"
  vars     = "${local.template_vars}"
}

## Build the "DenyAll for Unauthorized Users" Part of the Policy
data "template_file" "deny-all" {
  template = "${file("${local.template_dir}/statement_deny-all-but-authorized.json.partial")}"
  vars     = "${merge(local.template_vars, map("principal", data.template_file.principal.rendered))}"
}

## Build the "DenyAll except Get and List for ReadOnly Users" Part of the Policy
data "template_file" "deny-ro-ids" {
  template = "${local.template_vars["readonly_ids"] != "" ? file("${local.template_dir}/statement_deny-readonly-ids.json.partial") : ""}"
  vars     = "${local.template_vars}"
}

## Build the "DenyAll except Get and List for ReadOnly ARNs" Part of the Policy
data "template_file" "deny-ro-arns" {
  template = "${local.template_vars["readonly_arns"] != "" ? file("${local.template_dir}/statement_deny-readonly-arns.json.partial") : ""}"
  vars     = "${local.template_vars}"
}

## Build the "DenyAll administration actions except for admin users" Part of the Policy
data "template_file" "deny-admin" {
  template = "${local.template_vars["admin_ids"] != "" ? file("${local.template_dir}/statement_deny-administration.json.partial") : ""}"
  vars     = "${local.template_vars}"
}

locals {
  policy_statement = "${
    compact(concat(
      list(
        data.template_file.encrypt.rendered,
        data.template_file.deny-all.rendered,
        data.template_file.deny-ro-ids.rendered,
        data.template_file.deny-ro-arns.rendered,
        data.template_file.deny-admin.rendered,
        ), 
      var.extra_statements
    ))}"
}

## Build the Policy
data "template_file" "policy" {
  template     = "${file("${path.module}/templates/policy.json")}"
  vars {
    statements = "${join(",\n", local.policy_statement)}"
  }
}