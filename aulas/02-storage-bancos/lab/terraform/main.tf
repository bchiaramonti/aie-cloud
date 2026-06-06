terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      # >= 3.107 é obrigatório: use_free_limit / free_limit_exhaustion_behavior
      # (oferta gratuita do Azure SQL Database) foram adicionados nessa versão
      version = ">= 3.107, < 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.12"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

resource "random_string" "sufixo" {
  length  = 6
  upper   = false
  special = false
}

locals {
  tags = {
    aula         = "2"
    disciplina   = "cloud-cognitive"
    projeto      = "quantum-commerce"
    provisionado = "terraform"
  }
}

# Resource Group da Aula 2
resource "azurerm_resource_group" "rg" {
  name     = "rg-qc-aula02-${random_string.sufixo.result}"
  location = var.location
  tags     = local.tags
}

# Objeto do usuário autenticado (usado para conceder RBAC no Key Vault/Cosmos/Search)
data "azurerm_client_config" "current" {}
