variable "bucket_arn" {
  description = "(Required) Bucket for which we are building the policy"
  type        = "string"
}

variable "force_encrypt" {
  description = "Should we force encryption of anything uploaded?"
  default     = true
}

variable "write_users" {
  description = "If specified, any rw access must be from a user from that list, or role form next."
  type        = "list"
  default     = []
}

variable "write_roles" {
  description = "If specified, any rw access must be from a user form prev list, or role from that list."
  type        = "list"
  default     = []
}

variable "access_users" {
  description = "If specified, any read access must be from a user from that list, or role form next"
  type        = "list"
  default     = []
}

variable "access_roles" {
  description = "If specified, any read access must be from a user form prev list, or role from that list"
  type        = "list"
  default     = []
}

variable "access_principal" {
  description = "If specified, any read access must be from a principal from that list"
  type        = "list"
  default     = []
}

variable "extra_statements" {
  description = "Extra statements to include"
  type        = "list"
  default     = []
}
