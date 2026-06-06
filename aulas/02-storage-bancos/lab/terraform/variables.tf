variable "location" {
  # Brazil South costuma ser BLOQUEADO pela política "best available regions"
  # das contas Azure for Students (RequestDisallowedByAzure). eastus2 é um
  # padrão seguro. Se a sua conta bloquear eastus2, descubra a região permitida
  # (ver guia) e rode: terraform apply -var="location=<regiao>"
  description = "Região do Azure onde os recursos serão provisionados"
  type        = string
  default     = "eastus2"
}

variable "sql_admin_password" {
  description = "Senha do admin do Azure SQL Server. Gere uma forte com: openssl rand -base64 24"
  type        = string
  sensitive   = true
}
