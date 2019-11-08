## Get the bucket account information
data "aws_caller_identity" "bucket" {
  # add filter here
}

## Local variable to add the account root user to the rw_users
locals {
  write_users      = "${distinct(concat(list(data.aws_caller_identity.bucket.account_id), compact(var.write_users)))}"
  write_roles      = "${distinct(compact(var.write_roles))}"
  access_users     = "${distinct(compact(var.access_users))}"
  access_roles     = "${distinct(compact(var.access_roles))}"
  access_principal = "${distinct(compact(var.access_principal))}"
}

## Build the "Force encrypt" Part of the policy
data "template_file" "force-encrypt" {
  template     = "${var.force_encrypt ? file("${path.module}/templates/statement_force-encrypt.json.partial") : ""}"
  vars {
    bucket_arn = "${var.bucket_arn}"
  }
}

## Define principals who need Read Access
module "read_principal" {
  source = "./modules/json_list"
  list   = "${local.access_principal}"
}

## Define Users who need Read Only Acess
module "read_access" {
  source = "./modules/json_list"
  list   = "${concat(
    local.access_users,
    local.write_users,
    formatlist("%s:*", 
      concat(local.access_roles, local.write_roles))
    )}"
}

## Define Users who need Read Only Acess
module "write_access" {
  source = "./modules/json_list"
  list   = "${concat(
    local.write_users,
    formatlist("%s:*", local.write_roles))}"
}

## Build the "Principal" Part of the Policy
data "template_file" "principal" {
  template                = "${file("${path.module}/templates/${module.read_principal.list == "" ? "principal" : "not-principal"}.json.partial")}"
  vars {
    principal_type        = "AWS"
    authorized_principals = "${module.read_principal.list}"
  }
}

## Build the "DenyAll for Unauthorized Users" Part of the Policy
data "template_file" "unauthorized-users_deny-all" {
  template           = "${file("${path.module}/templates/statement_deny-all-but-authorized.json.partial")}"
  vars {
    bucket_arn       = "${var.bucket_arn}"
    principal        = "${data.template_file.principal.rendered}"
    authorized_users = "${module.read_access.list}"
  }
}

## Build the "DenyAll except Get and List for Unauthorized Users" Part of the Policy
data "template_file" "unauthorized-users_deny-write" {
  template           = "${file("${path.module}/templates/statement_deny-all-write-but-authorized.json.partial")}"
  vars {
    bucket_arn       = "${var.bucket_arn}"
    principal        = "\"Principal\": {\n                \"AWS\": \"*\"\n            }"
    authorized_users = "${module.write_access.list}"
  }
}

## Build the Policy
data "template_file" "policy" {
  template     = "${file("${path.module}/templates/policy.json")}"
  vars {
    statements = "${join(",\n",
        compact(
          concat(
            list(
              data.template_file.force-encrypt.rendered,
              data.template_file.unauthorized-users_deny-all.rendered,
              data.template_file.unauthorized-users_deny-write.rendered,
            ),
            var.extra_statements
          )
        )
    )}"
  }
}
