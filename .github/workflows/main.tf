terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

 backend "azurerm" {
    resource_group_name   = "backupcode"
    storage_account_name  = "backupdatastorage1"
    container_name        = "backup"
    key                   = "infra/terraform.tfstate"
    subscription_id       = "fb656642-6401-44d5-9de1-14bda10d53e5"  # Add this explicitly
  }
}

provider "azurerm" {
  features {}
}

# Create Resource Group
resource "azurerm_resource_group" "backupcode" {
  name     = "backupcode"
  location = "East US"
}

# Create Storage Account for Backup
resource "azurerm_storage_account" "backup_storage" {
  name                     = "backupdatastorage1"
  resource_group_name      = azurerm_resource_group.backupcode.name
  location                 = azurerm_resource_group.backupcode.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    Environment = "dev"
  }
}

# Create Recovery Services Vault
resource "azurerm_recovery_services_vault" "backup_vault" {
  name                = "backup-vault"
  resource_group_name = azurerm_resource_group.backupcode.name
  location            = azurerm_resource_group.backupcode.location
  sku                 = "Standard"

  tags = {
    Environment = "dev"
  }
}

# Create VM Backup Policy
resource "azurerm_backup_policy_vm" "vm_backup_policy" {
  name                = "daily-vm-backup-policy"
  resource_group_name = azurerm_resource_group.backupcode.name
  recovery_vault_name = azurerm_recovery_services_vault.backup_vault.name

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 7
  }
}

# Enable Backup for an Azure VM
resource "azurerm_backup_protected_vm" "vm_backup" {
  resource_group_name = azurerm_resource_group.backupcode.name
  recovery_vault_name = azurerm_recovery_services_vault.backup_vault.name
  source_vm_id        = "/subscriptions/fb656642-6401-44d5-9de1-14bda10d53e5/resourceGroups/backupcode/providers/Microsoft.Compute/virtualMachines/backupvm"
  backup_policy_id    = azurerm_backup_policy_vm.vm_backup_policy.id
}

# Outputs
output "storage_account_name" {
  value = azurerm_storage_account.backup_storage.name
}

output "backup_vault_name" {
  value = azurerm_recovery_services_vault.backup_vault.name
}
