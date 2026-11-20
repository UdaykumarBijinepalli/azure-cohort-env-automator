module "cohort01_lab" {
  source = "../../modules/cohort_lab"

  cohort_id             = var.cohort_id
  location              = var.location
  owner_email           = var.owner_email
  monthly_budget_amount = var.monthly_budget_amount
}

output "cohort_resource_group" {
  value = module.cohort01_lab.resource_group_name
}

output "cohort_storage_account" {
  value = module.cohort01_lab.storage_account_name
}

output "cohort_cosmos_endpoint" {
  value = module.cohort01_lab.cosmosdb_endpoint
}
