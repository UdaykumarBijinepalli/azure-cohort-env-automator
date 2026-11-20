variable "cohort_id" {
  description = "Unique identifier for the training cohort (e.g., cohort01)"
  type        = string
}

variable "location" {
  description = "Azure region for cohort lab deployment"
  type        = string
  default     = "centralindia"
}

variable "owner_email" {
  description = "Email address for resource tagging and budget notifications"
  type        = string
}

variable "vnet_address_space" {
  description = "CIDR block for the isolated cohort VNet"
  type        = list(string)
  default     = ["10.10.0.0/16"]
}

variable "subnet_prefix" {
  description = "CIDR block for the cohort lab subnet"
  type        = string
  default     = "10.10.1.0/24"
}

variable "monthly_budget_amount" {
  description = "Monthly spend threshold in USD for Azure Budget alert"
  type        = number
  default     = 10
}
