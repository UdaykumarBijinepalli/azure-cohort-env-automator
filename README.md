# Azure Cohort Environment Automator

Automated GitOps Infrastructure-as-Code (IaC) pipeline that provisions isolated, policy-governed Azure training environments for student cohorts and executes verified zero-orphan teardowns post-training.

## Architecture

* **CI/CD & Auth:** GitHub Actions authenticating to Microsoft Entra ID via passwordless OpenID Connect (OIDC) Workload Identity Federation.
* **Remote State:** Azure Blob Storage backend with Entra ID RBAC (Storage Blob Data Contributor) and state locking.
* **Provisioned Stack (cohort_lab module):** Resource Group (rg-cohort01-lab), isolated VNet (10.10.0.0/16) & Subnet (10.10.1.0/24), Default-Deny Inbound NSG, TLS 1.2 Storage Account, Azure Cosmos DB (Free Tier) + SQL Database, Azure Policy (Require CohortID Tag), and FinOps Budget Alert (80% threshold).
* **Post-Training Teardown:** Guarded teardown workflow (DESTROY input check) running terraform destroy followed by Azure CLI assertion verifying zero orphaned Resource Groups.

## Usage

1. **Provision:** Push changes under terraform/ to main or trigger Provision Cohort Lab Environment in GitHub Actions.
2. **Teardown:** Run Post-Training Cohort Lab Teardown in GitHub Actions with DESTROY to clean up all cohort resources.
