output "force-encrypt" {
   value = "${data.template_file.force-encrypt.rendered}"
}

output "unauthorized-users_deny-all" {
   value = "${data.template_file.unauthorized-users_deny-all.rendered}"
}

output "unauthorized-users_deny-write" {
   value = "${data.template_file.unauthorized-users_deny-write.rendered}"
}

output "policy" {
   value = "${data.template_file.policy.rendered}"
}