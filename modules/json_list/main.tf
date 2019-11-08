locals {
  list = "${distinct(concat(compact(var.list)))}"
  json = "${join(", ", formatlist("\"%s\"", local.list))}"
}
