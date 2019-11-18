output "policy" {
  value = "${data.template_file.policy.rendered}"
}