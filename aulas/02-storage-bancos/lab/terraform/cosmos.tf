# Cosmos DB Account — Free Tier habilitado (apenas 1 por assinatura é permitido)
# Se já houver outra Cosmos com free_tier nesta subscription, mude para false (terá custo simbólico).
resource "azurerm_cosmosdb_account" "qc" {
  name                = "cosmos-qc-${random_string.sufixo.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"
  free_tier_enabled   = true

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = azurerm_resource_group.rg.location
    failover_priority = 0
  }

  capabilities {
    name = "EnableServerless"
  }

  tags = local.tags
}

# Database
resource "azurerm_cosmosdb_sql_database" "qc" {
  name                = "qc-db"
  resource_group_name = azurerm_resource_group.rg.name
  account_name        = azurerm_cosmosdb_account.qc.name
}

# Container de reviews — particionado por produto_id
resource "azurerm_cosmosdb_sql_container" "reviews" {
  name                = "reviews"
  resource_group_name = azurerm_resource_group.rg.name
  account_name        = azurerm_cosmosdb_account.qc.name
  database_name       = azurerm_cosmosdb_sql_database.qc.name
  partition_key_paths = ["/produto_id"]
}
