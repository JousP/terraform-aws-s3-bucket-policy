variable "bucket_arn" {
  description = "(Required) Bucket for which we are building the policy"
  type        = string
}

variable "force_encrypt" {
  description = "(Optional) Specifies whether the encryption of anything uploaded is forced"
  type        = bool
  default     = true
}

variable "admin_users_id" {
  description = "A list of IAM users unique_id to grant administration access."
  type        = list(string)
  default     = []
}

variable "admin_roles_id" {
  description = "A list of IAM roles unique_id to grant administration access."
  type        = list(string)
  default     = []
}

variable "readwrite_users_id" {
  description = "A list of IAM users unique_id to grant read and write access."
  type        = list(string)
  default     = []
}

variable "readwrite_roles_id" {
  description = "A list of IAM roles unique_id to grant read and write access."
  type        = list(string)
  default     = []
}

variable "readwrite_arn" {
  description = "list of ARN to grant read and write access."
  type        = list(string)
  default     = []
}

variable "readonly_users_id" {
  description = "A list of IAM users unique_id to grant read only access."
  type        = list(string)
  default     = []
}

variable "readonly_roles_id" {
  description = "A list of IAM roles unique_id to grant read only access."
  type        = list(string)
  default     = []
}

variable "readonly_arns" {
  description = "list of ARN to grant read only access."
  type        = list(string)
  default     = []
}

variable "extra_statements" {
  description = "Extra statements to include"
  type        = list(string)
  default     = []
}
