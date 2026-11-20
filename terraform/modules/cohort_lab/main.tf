resource "random_string" "suffix" {
  length  = 5
  special = false
  upper   = false
}

locals {
  common_tags = {
    CohortID    = var.cohort_id
    Owner       = var.owner_email
    Environment = "TrainingLab"
    ManagedBy   = "Terraform-GitHubActions"
  }
}

# 1. Isolated Cohort Resource Group
resource "azurerm_resource_group" "cohort" {
  name     = "rg-${var.cohort_id}-lab"
  location = var.location
  tags     = local.common_tags
}

# 2. Network Security Group (Default Deny Inbound)
resource "azurerm_network_security_group" "cohort_nsg" {
  name                = "nsg-${var.cohort_id}-lab"
  location            = azurerm_resource_group.cohort.location
  resource_group_name = azurerm_resource_group.cohort.name
  tags                = local.common_tags

  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# 3. Virtual Network & Lab Subnet
resource "azurerm_virtual_network" "cohort_vnet" {
  name                = "vnet-${var.cohort_id}-lab"
  location            = azurerm_resource_group.cohort.location
  resource_group_name = azurerm_resource_group.cohort.name
  address_space       = var.vnet_address_space
  tags                = local.common_tags
}

resource "azurerm_subnet" "lab_subnet" {
  name                 = "snet-${var.cohort_id}-workloads"
  resource_group_name  = azurerm_resource_group.cohort.name
  virtual_network_name = azurerm_virtual_network.cohort_vnet.name
  address_prefixes     = [var.subnet_prefix]
}

resource "azurerm_subnet_network_security_group_association" "lab_nsg_assoc" {
  subnet_id                 = azurerm_subnet.lab_subnet.id
  network_security_group_id = azurerm_network_security_group.cohort_nsg.id
}

# 4. Cohort Storage Account & Artifacts Container
resource "azurerm_storage_account" "cohort_sa" {
  name                            = "st${var.cohort_id}${random_string.suffix.result}"
  resource_group_name             = azurerm_resource_group.cohort.name
  location                        = azurerm_resource_group.cohort.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  tags                            = local.common_tags
}

resource "azurerm_storage_container" "artifacts" {
  name                  = "lab-artifacts"
  storage_account_id    = azurerm_storage_account.cohort_sa.id
  container_access_type = "private"
}

# 5. Azure Cosmos DB (Free Tier) + SQL Database
resource "azurerm_cosmosdb_account" "cohort_cosmos" {
  name                = "cosmos-${var.cohort_id}-${random_string.suffix.result}"
  location            = azurerm_resource_group.cohort.location
  resource_group_name = azurerm_resource_group.cohort.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"
  free_tier_enabled   = true
  tags                = local.common_tags

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = azurerm_resource_group.cohort.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_sql_database" "cohort_db" {
  name                = "${var.cohort_id}-telemetry-db"
  resource_group_name = azurerm_resource_group.cohort.name
  account_name        = azurerm_cosmosdb_account.cohort_cosmos.name
  throughput          = 400
}

# 6. Azure Policy: Enforce Mandatory CohortID Tag on All Resources
data "azurerm_policy_definition" "require_tag" {
  display_name = "Require a tag on resources"
}

resource "azurerm_resource_group_policy_assignment" "enforce_cohort_tag" {
  name                 = "enforce-cohort-id-tag"
  resource_group_id    = azurerm_resource_group.cohort.id
  policy_definition_id = data.azurerm_policy_definition.require_tag.id
  description          = "Enforces mandatory CohortID governance tag on all cohort lab resources."
  display_name         = "Require CohortID Tag on Lab Resources"

  parameters = jsonencode({
    tagName = {
      value = "CohortID"
    }
  })
}

# 7. FinOps Cost Management Budget Alert
resource "azurerm_consumption_budget_resource_group" "cohort_budget" {
  name              = "budget-${var.cohort_id}-monthly"
  resource_group_id = azurerm_resource_group.cohort.id

  amount     = var.monthly_budget_amount
  time_grain = "Monthly"

  time_period {
    start_date = "2026-11-01T00:00:00Z"
  }

  notification {
    enabled        = true
    threshold      = 80.0
    operator       = "GreaterThan"
    threshold_type = "Actual"

    contact_emails = [
      var.owner_email
    ]
  }
}
