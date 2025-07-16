# Outputs for Minimal Spec AKS Cluster
# These outputs provide important information about the deployed resources
# for downstream usage and integration.

output "aks_cluster_id" {
  description = "The resource ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.id
}

output "aks_cluster_name" {
  description = "The name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.name
}

output "aks_cluster_fqdn" {
  description = "The FQDN of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.fqdn
}

output "aks_cluster_portal_fqdn" {
  description = "The Azure Portal FQDN of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.portal_fqdn
}

output "aks_cluster_private_fqdn" {
  description = "The private FQDN of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.private_fqdn
}

output "aks_node_resource_group" {
  description = "The auto-generated resource group containing the AKS nodes"
  value       = azurerm_kubernetes_cluster.main.node_resource_group
}

output "managed_identity_id" {
  description = "The resource ID of the user-assigned managed identity"
  value       = azurerm_user_assigned_identity.aks_identity.id
}

output "managed_identity_client_id" {
  description = "The client ID of the user-assigned managed identity"
  value       = azurerm_user_assigned_identity.aks_identity.client_id
}

output "managed_identity_principal_id" {
  description = "The principal ID of the user-assigned managed identity"
  value       = azurerm_user_assigned_identity.aks_identity.principal_id
  sensitive   = var.output_sensitive_values
}

output "log_analytics_workspace_id" {
  description = "The resource ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.id
}

output "log_analytics_workspace_name" {
  description = "The name of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.name
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "The location of the resource group"
  value       = azurerm_resource_group.main.location
}

output "oidc_issuer_url" {
  description = "The OIDC issuer URL for workload identity"
  value       = azurerm_kubernetes_cluster.main.oidc_issuer_url
}

output "kubelet_identity" {
  description = "The kubelet managed identity information"
  value = {
    client_id                 = azurerm_kubernetes_cluster.main.kubelet_identity[0].client_id
    object_id                = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
    user_assigned_identity_id = azurerm_kubernetes_cluster.main.kubelet_identity[0].user_assigned_identity_id
  }
  sensitive = var.output_sensitive_values
}

output "cluster_configuration" {
  description = "Key configuration details of the AKS cluster"
  value = {
    kubernetes_version    = azurerm_kubernetes_cluster.main.kubernetes_version
    current_version      = azurerm_kubernetes_cluster.main.current_kubernetes_version
    dns_prefix           = azurerm_kubernetes_cluster.main.dns_prefix
    sku_tier            = azurerm_kubernetes_cluster.main.sku_tier
    network_plugin      = azurerm_kubernetes_cluster.main.network_profile[0].network_plugin
    load_balancer_sku   = azurerm_kubernetes_cluster.main.network_profile[0].load_balancer_sku
    node_count          = azurerm_kubernetes_cluster.main.default_node_pool[0].node_count
    vm_size             = azurerm_kubernetes_cluster.main.default_node_pool[0].vm_size
  }
}

output "cost_information" {
  description = "Estimated cost information for the deployment"
  value = {
    sku_tier                = azurerm_kubernetes_cluster.main.sku_tier
    estimated_monthly_cost  = "~$60-75 USD"
    cost_components = {
      aks_control_plane = "Free (Free tier)"
      vm_nodes         = "~$30-40/month per ${azurerm_kubernetes_cluster.main.default_node_pool[0].vm_size} node"
      managed_disk     = "~$5/month per 30GB disk"
      load_balancer    = "~$20/month"
      log_analytics    = "~$5-10/month"
    }
    cost_optimization_notes = [
      "Free tier AKS control plane",
      "Minimal node configuration",
      "Basic monitoring setup",
      "No premium add-ons enabled"
    ]
  }
}

output "connection_commands" {
  description = "Commands to connect to and manage the AKS cluster"
  value = {
    get_credentials    = "az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${azurerm_kubernetes_cluster.main.name}"
    kubectl_config     = "kubectl config current-context"
    view_nodes        = "kubectl get nodes"
    view_pods         = "kubectl get pods --all-namespaces"
    cluster_info      = "kubectl cluster-info"
  }
}

output "azure_portal_urls" {
  description = "Azure Portal URLs for managing resources"
  value = {
    aks_cluster     = "https://portal.azure.com/#resource${azurerm_kubernetes_cluster.main.id}/overview"
    resource_group  = "https://portal.azure.com/#resource${azurerm_resource_group.main.id}/overview"
    log_analytics   = "https://portal.azure.com/#resource${azurerm_log_analytics_workspace.main.id}/overview"
    managed_identity = "https://portal.azure.com/#resource${azurerm_user_assigned_identity.aks_identity.id}/overview"
  }
}

output "next_steps" {
  description = "Recommended next steps after deployment"
  value = [
    "1. Configure kubectl: ${local.connection_command}",
    "2. Verify cluster status: kubectl get nodes",
    "3. Deploy sample application: kubectl create deployment nginx --image=nginx",
    "4. Monitor cluster health in Azure Portal",
    "5. Set up additional monitoring and alerting as needed",
    "6. Review and implement security best practices",
    "7. Plan for scaling based on application requirements"
  ]
}

# Local values for computed outputs
locals {
  connection_command = "az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${azurerm_kubernetes_cluster.main.name}"
}
