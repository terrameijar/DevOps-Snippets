variable "adminusername" {
  description = "The admin username"
  type        = string
  default     = "vuyisile"
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  sensitive   = true
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
  sensitive   = true
}

variable "key_vault_name" {
  description = "Azure Key Vault Name"
  type        = string
  sensitive   = false
  default     = "vndlovu-migrationlab-kv"
}

variable "user_object_id" {
  description = "Azure Object ID"
  type        = string
}


variable "postgres_administrator_login" {
  description = "Postgresql Flexible Server admin user"
  type        = string
}

variable "postgres_administrator_password" {
  description = "Postgresql Flexible Server admin password"
  type        = string
  sensitive   = true
}
