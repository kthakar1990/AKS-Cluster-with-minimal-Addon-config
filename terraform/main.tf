# Minimal Spec AKS Cluster - Terraform Configuration
# This configuration creates a cost-optimized AKS cluster following Terraform best practices
# and Azure security standards.

terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.45"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

# Configure the Azure Provider
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

# Data sources
data "azurerm_client_config" "current" {}

# Random string for unique resource naming
resource "random_string" "resource_token" {
  length  = 8
  special = false
  upper   = false
}

# Local variables for resource configuration
locals {
  resource_token = random_string.resource_token.result
  common_tags = {
    environment     = var.environment
    "azd-env-name" = var.environment
    purpose        = "minimal-aks-cluster"
    cost_optimized = "true"
    created_by     = "terraform"
    project        = "minimal-spec-aks"
  }
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.common_tags
}

# User Assigned Managed Identity for AKS
resource "azurerm_user_assigned_identity" "aks_identity" {
  name                = "id-${var.cluster_name}-${local.resource_token}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.common_tags
}

# Log Analytics Workspace for monitoring
resource "azurerm_log_analytics_workspace" "main" {
  name                = "log-${var.cluster_name}-${local.resource_token}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
  tags                = local.common_tags
}

# AKS Cluster with minimal specifications
resource "azurerm_kubernetes_cluster" "main" {
  name                      = var.cluster_name
  location                  = azurerm_resource_group.main.location
  resource_group_name       = azurerm_resource_group.main.name
  dns_prefix                = var.dns_prefix != "" ? var.dns_prefix : var.cluster_name
  kubernetes_version        = var.kubernetes_version
  sku_tier                  = "Free" # Free tier for cost optimization
  local_account_disabled    = false  # Keep local accounts for simplicity
  role_based_access_control_enabled = true

  # Default node pool configuration - minimal spec
  default_node_pool {
    name                = "nodepool1"
    node_count          = var.node_count
    vm_size             = var.node_vm_size
    type                = "VirtualMachineScaleSets"
    os_disk_size_gb     = 30
    os_disk_type        = "Managed"
    os_sku              = "Ubuntu"
    max_pods            = 30
    enable_auto_scaling = false
    enable_node_public_ip = false
    enable_host_encryption = false
    ultra_ssd_enabled   = false

    upgrade_settings {
      max_surge = "1"
    }

    tags = local.common_tags
  }

  # Network configuration - kubenet for cost efficiency
  network_profile {
    network_plugin     = "kubenet"
    load_balancer_sku  = "standard"
    network_policy     = "none" # Simplified for minimal spec
    pod_cidr          = "10.244.0.0/16"
    service_cidr      = "10.0.0.0/16"
    dns_service_ip    = "10.0.0.10"
  }

  # Identity configuration using user-assigned managed identity
  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.aks_identity.id
    ]
  }

  # Auto-upgrade configuration
  automatic_channel_upgrade     = "patch"
  node_os_channel_upgrade      = "NodeImage"

  # OIDC Issuer for workload identity
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  # Azure Monitor integration
  oms_agent {
    log_analytics_workspace_id      = azurerm_log_analytics_workspace.main.id
    msi_auth_for_monitoring_enabled = true
  }

  # Key Vault Secrets Provider (disabled for minimal spec)
  key_vault_secrets_provider {
    secret_rotation_enabled = false
  }

  # Storage profile with minimal configuration
  storage_profile {
    blob_driver_enabled         = false
    disk_driver_enabled         = true
    file_driver_enabled         = false
    snapshot_controller_enabled = false
  }

  # Azure Policy (disabled for cost optimization)
  azure_policy_enabled = false

  # HTTP Application Routing (deprecated and disabled)
  http_application_routing_enabled = false

  tags = local.common_tags

  depends_on = [
    azurerm_role_assignment.aks_acr_pull
  ]
}

# Role assignment for AKS managed identity to pull from ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = azurerm_resource_group.main.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
  principal_type       = "ServicePrincipal"
}

# Role assignment for AKS kubelet identity to manage network resources
resource "azurerm_role_assignment" "aks_network_contributor" {
  scope                = azurerm_resource_group.main.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
  principal_type       = "ServicePrincipal"
}
