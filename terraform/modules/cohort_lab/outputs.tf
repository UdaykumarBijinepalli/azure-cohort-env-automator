output "resource_group_name" {
  description = "Provisioned cohort Resource Group name"
  value       = azurerm_resource_group.cohort.name
}

output "vnet_id" {
  description = "ID of the isolated cohort Virtual Network"
  value       = azurerm_virtual_network.cohort_vnet.id
}

output "storage_account_name" {
  description = "Cohort lab Storage Account name"
  value       = azurerm_storage_account.cohort_sa.name
}

output "cosmosdb_endpoint" {
  description = "Cohort Cosmos DB endpoint URI"
  value       = azurerm_cosmosdb_account.cohort_cosmos.endpoint
}
