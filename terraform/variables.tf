# Variables for Minimal Spec AKS Cluster Configuration
# These variables allow customization of the AKS deployment while maintaining
# cost optimization and minimal specifications.

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "aks-minimal-tf"
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9]([a-zA-Z0-9-_]*[a-zA-Z0-9])?$", var.cluster_name))
    error_message = "Cluster name must be alphanumeric and can contain hyphens and underscores."
  }
  
  validation {
    condition     = length(var.cluster_name) >= 3 && length(var.cluster_name) <= 63
    error_message = "Cluster name must be between 3 and 63 characters."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-minimal-aks-tf"
}

variable "location" {
  description = "Azure region for resource deployment"
  type        = string
  default     = "East US"
  
  validation {
    condition = contains([
      "East US", "East US 2", "West US", "West US 2", "West US 3",
      "Central US", "North Central US", "South Central US",
      "Canada Central", "Canada East",
      "West Europe", "North Europe", "UK South", "UK West",
      "Germany West Central", "Switzerland North", "France Central",
      "Australia East", "Australia Southeast",
      "Japan East", "Japan West",
      "Korea Central", "Korea South",
      "Southeast Asia", "East Asia",
      "Central India", "South India", "West India"
    ], var.location)
    error_message = "Please specify a valid Azure region."
  }
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster (optional, defaults to cluster_name)"
  type        = string
  default     = ""
}

variable "kubernetes_version" {
  description = "Kubernetes version for the cluster"
  type        = string
  default     = "1.28.3"
  
  validation {
    condition     = can(regex("^1\\.(2[6-9]|[3-9][0-9])\\.[0-9]+$", var.kubernetes_version))
    error_message = "Kubernetes version must be 1.26 or higher in format x.y.z."
  }
}

variable "node_vm_size" {
  description = "VM size for the default node pool (minimal spec optimized)"
  type        = string
  default     = "Standard_B2s"
  
  validation {
    condition = contains([
      "Standard_B2s",
      "Standard_DS2_v2",
      "Standard_D2s_v3",
      "Standard_D2s_v4",
      "Standard_D2s_v5"
    ], var.node_vm_size)
    error_message = "Node VM size must be one of the approved minimal spec sizes."
  }
}

variable "node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 1
  
  validation {
    condition     = var.node_count >= 1 && var.node_count <= 5
    error_message = "Node count must be between 1 and 5 for minimal spec."
  }
}

variable "environment" {
  description = "Environment name for resource tagging"
  type        = string
  default     = "dev"
  
  validation {
    condition = contains([
      "dev", "development",
      "test", "testing",
      "staging", "stage",
      "prod", "production"
    ], var.environment)
    error_message = "Environment must be one of: dev, development, test, testing, staging, stage, prod, production."
  }
}

variable "log_retention_days" {
  description = "Number of days to retain logs in Log Analytics workspace"
  type        = number
  default     = 30
  
  validation {
    condition     = var.log_retention_days >= 30 && var.log_retention_days <= 730
    error_message = "Log retention must be between 30 and 730 days."
  }
}

variable "enable_auto_scaling" {
  description = "Enable auto-scaling for the default node pool"
  type        = bool
  default     = false
}

variable "min_node_count" {
  description = "Minimum number of nodes when auto-scaling is enabled"
  type        = number
  default     = 1
  
  validation {
    condition     = var.min_node_count >= 1 && var.min_node_count <= 10
    error_message = "Minimum node count must be between 1 and 10."
  }
}

variable "max_node_count" {
  description = "Maximum number of nodes when auto-scaling is enabled"
  type        = number
  default     = 3
  
  validation {
    condition     = var.max_node_count >= 1 && var.max_node_count <= 10
    error_message = "Maximum node count must be between 1 and 10."
  }
}

variable "pod_cidr" {
  description = "CIDR range for pod IPs (when using kubenet)"
  type        = string
  default     = "10.244.0.0/16"
  
  validation {
    condition     = can(cidrhost(var.pod_cidr, 0))
    error_message = "Pod CIDR must be a valid CIDR notation."
  }
}

variable "service_cidr" {
  description = "CIDR range for service IPs"
  type        = string
  default     = "10.0.0.0/16"
  
  validation {
    condition     = can(cidrhost(var.service_cidr, 0))
    error_message = "Service CIDR must be a valid CIDR notation."
  }
}

variable "dns_service_ip" {
  description = "IP address for the Kubernetes DNS service"
  type        = string
  default     = "10.0.0.10"
  
  validation {
    condition     = can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.dns_service_ip))
    error_message = "DNS service IP must be a valid IP address."
  }
}

variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Output variable descriptions for documentation
variable "output_sensitive_values" {
  description = "Whether to mark outputs as sensitive"
  type        = bool
  default     = false
}
