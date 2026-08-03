variable "environment" {
  type        = string
  description = "Environment name (e.g. dev, staging, prod)"
  default     = "dev"
}

variable "mongodb_uri" {
  type        = string
  description = "Initial/default MongoDB connection URI for Secrets Manager"
  default     = "mongodb+srv://dev_user:dev_password@cluster0.example.mongodb.net/prop_agent"
  sensitive   = true
}

variable "okta_client_id" {
  type        = string
  description = "Okta OIDC Client ID"
  default     = "dev-okta-client-id"
}

variable "okta_issuer_url" {
  type        = string
  description = "Okta Issuer URL"
  default     = "https://dev-identity.okta.com/oauth2/default"
}

variable "salesforce_client_id" {
  type        = string
  description = "Salesforce OAuth Client ID"
  default     = "dev-salesforce-client-id"
}

variable "salesforce_client_secret" {
  type        = string
  description = "Salesforce OAuth Client Secret"
  default     = "dev-salesforce-client-secret"
  sensitive   = true
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}
