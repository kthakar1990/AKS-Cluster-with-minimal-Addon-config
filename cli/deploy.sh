#!/bin/bash

# Minimal Spec AKS Cluster Deployment Script
# This script creates a cost-optimized AKS cluster using Azure CLI
# 
# Prerequisites:
# - Azure CLI installed and configured
# - Appropriate Azure subscription access
# - Bash shell environment

set -euo pipefail  # Exit on error, undefined variables, pipe failures

# Configuration variables
CLUSTER_NAME="${CLUSTER_NAME:-aks-minimal-cli-$(date +%s)}"
RESOURCE_GROUP="${RESOURCE_GROUP:-rg-minimal-aks}"
LOCATION="${LOCATION:-eastus}"
NODE_COUNT="${NODE_COUNT:-1}"
NODE_VM_SIZE="${NODE_VM_SIZE:-Standard_B2s}"
KUBERNETES_VERSION="${KUBERNETES_VERSION:-1.28.3}"
ENVIRONMENT="${ENVIRONMENT:-dev}"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if Azure CLI is installed
    if ! command -v az &> /dev/null; then
        print_error "Azure CLI is not installed. Please install it first."
        exit 1
    fi
    
    # Check if user is logged in
    if ! az account show &> /dev/null; then
        print_error "Not logged into Azure. Please run 'az login' first."
        exit 1
    fi
    
    # Check if kubectl is available (for post-deployment configuration)
    if ! command -v kubectl &> /dev/null; then
        print_warning "kubectl is not installed. You won't be able to manage the cluster immediately."
    fi
    
    print_success "Prerequisites check completed"
}

# Function to create resource group
create_resource_group() {
    print_status "Creating resource group: $RESOURCE_GROUP in $LOCATION..."
    
    az group create \
        --name "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --tags environment="$ENVIRONMENT" purpose="minimal-aks-cluster" cost-optimized="true" \
        --output table
    
    print_success "Resource group created successfully"
}

# Function to create Log Analytics workspace
create_log_analytics() {
    local workspace_name="log-${CLUSTER_NAME}"
    
    print_status "Creating Log Analytics workspace: $workspace_name..."
    
    az monitor log-analytics workspace create \
        --resource-group "$RESOURCE_GROUP" \
        --workspace-name "$workspace_name" \
        --location "$LOCATION" \
        --sku PerGB2018 \
        --retention-time 30 \
        --tags environment="$ENVIRONMENT" purpose="aks-monitoring" \
        --output table
    
    # Get workspace resource ID for AKS integration
    WORKSPACE_ID=$(az monitor log-analytics workspace show \
        --resource-group "$RESOURCE_GROUP" \
        --workspace-name "$workspace_name" \
        --query id \
        --output tsv)
    
    print_success "Log Analytics workspace created successfully"
}

# Function to create AKS cluster
create_aks_cluster() {
    print_status "Creating minimal spec AKS cluster: $CLUSTER_NAME..."
    print_status "This may take 10-15 minutes..."
    
    az aks create \
        --resource-group "$RESOURCE_GROUP" \
        --name "$CLUSTER_NAME" \
        --location "$LOCATION" \
        --kubernetes-version "$KUBERNETES_VERSION" \
        --node-count "$NODE_COUNT" \
        --node-vm-size "$NODE_VM_SIZE" \
        --node-osdisk-size 30 \
        --max-pods 30 \
        --load-balancer-sku standard \
        --network-plugin kubenet \
        --pod-cidr 10.244.0.0/16 \
        --service-cidr 10.0.0.0/16 \
        --dns-service-ip 10.0.0.10 \
        --enable-managed-identity \
        --enable-addons monitoring \
        --workspace-resource-id "$WORKSPACE_ID" \
        --enable-oidc-issuer \
        --enable-workload-identity \
        --tier Free \
        --disable-local-accounts false \
        --enable-rbac \
        --tags environment="$ENVIRONMENT" purpose="minimal-aks-cluster" cost-optimized="true" \
        --output table
    
    print_success "AKS cluster created successfully"
}

# Function to configure kubectl
configure_kubectl() {
    print_status "Configuring kubectl for cluster access..."
    
    if command -v kubectl &> /dev/null; then
        az aks get-credentials \
            --resource-group "$RESOURCE_GROUP" \
            --name "$CLUSTER_NAME" \
            --overwrite-existing
        
        # Test cluster connectivity
        if kubectl cluster-info &> /dev/null; then
            print_success "kubectl configured successfully"
            kubectl get nodes
        else
            print_warning "kubectl configuration completed but connectivity test failed"
        fi
    else
        print_warning "kubectl not found. Install kubectl to manage your cluster"
        print_status "Configure kubectl manually with:"
        echo "  az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME"
    fi
}

# Function to display cluster information
display_cluster_info() {
    print_status "Retrieving cluster information..."
    
    # Get cluster details
    CLUSTER_FQDN=$(az aks show \
        --resource-group "$RESOURCE_GROUP" \
        --name "$CLUSTER_NAME" \
        --query fqdn \
        --output tsv)
    
    CLUSTER_ID=$(az aks show \
        --resource-group "$RESOURCE_GROUP" \
        --name "$CLUSTER_NAME" \
        --query id \
        --output tsv)
    
    echo
    echo "========================================="
    echo "         CLUSTER DEPLOYMENT SUMMARY     "
    echo "========================================="
    echo "Cluster Name:     $CLUSTER_NAME"
    echo "Resource Group:   $RESOURCE_GROUP"
    echo "Location:         $LOCATION"
    echo "K8s Version:      $KUBERNETES_VERSION"
    echo "Node Count:       $NODE_COUNT"
    echo "Node VM Size:     $NODE_VM_SIZE"
    echo "Cluster FQDN:     $CLUSTER_FQDN"
    echo "Environment:      $ENVIRONMENT"
    echo
    echo "Portal URL:       https://portal.azure.com/#resource$CLUSTER_ID/overview"
    echo
    echo "Connect to cluster:"
    echo "  az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME"
    echo
    echo "Monitor cluster:"
    echo "  kubectl get nodes"
    echo "  kubectl get pods --all-namespaces"
    echo "========================================="
}

# Function to show cost estimation
show_cost_estimation() {
    print_status "Estimated monthly cost breakdown:"
    echo
    echo "Component                    Estimated Cost (USD)"
    echo "----------------------------------------"
    echo "AKS Control Plane           Free (Free tier)"
    echo "Standard_B2s VM (1 node)    ~$30-40/month"
    echo "Managed Disk (30GB)         ~$5/month"
    echo "Load Balancer               ~$20/month"
    echo "Log Analytics (30 days)     ~$5-10/month"
    echo "Network traffic             Variable"
    echo "----------------------------------------"
    echo "Total Estimated Cost:       ~$60-75/month"
    echo
    print_warning "Actual costs may vary based on usage, region, and resource consumption"
}

# Function to clean up on error
cleanup_on_error() {
    if [[ $? -ne 0 ]]; then
        print_error "Deployment failed. Check the error messages above."
        print_status "To clean up resources, run:"
        echo "  az group delete --name $RESOURCE_GROUP --yes --no-wait"
    fi
}

# Main deployment function
main() {
    echo "========================================="
    echo "    MINIMAL SPEC AKS CLUSTER DEPLOYMENT "
    echo "========================================="
    echo
    
    trap cleanup_on_error EXIT
    
    check_prerequisites
    create_resource_group
    create_log_analytics
    create_aks_cluster
    configure_kubectl
    display_cluster_info
    show_cost_estimation
    
    trap - EXIT
    print_success "Deployment completed successfully!"
}

# Show usage information
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Environment Variables (optional):"
    echo "  CLUSTER_NAME      Name of the AKS cluster (default: aks-minimal-cli-timestamp)"
    echo "  RESOURCE_GROUP    Resource group name (default: rg-minimal-aks)"
    echo "  LOCATION          Azure region (default: eastus)"
    echo "  NODE_COUNT        Number of nodes (default: 1)"
    echo "  NODE_VM_SIZE      VM size (default: Standard_B2s)"
    echo "  KUBERNETES_VERSION K8s version (default: 1.28.3)"
    echo "  ENVIRONMENT       Environment tag (default: dev)"
    echo
    echo "Example:"
    echo "  CLUSTER_NAME=my-aks LOCATION=westus2 $0"
    echo
    echo "Options:"
    echo "  -h, --help        Show this help message"
    echo "  -i, --info        Show current configuration"
}

# Show current configuration
show_config() {
    echo "Current Configuration:"
    echo "  Cluster Name:     $CLUSTER_NAME"
    echo "  Resource Group:   $RESOURCE_GROUP"
    echo "  Location:         $LOCATION"
    echo "  Node Count:       $NODE_COUNT"
    echo "  Node VM Size:     $NODE_VM_SIZE"
    echo "  K8s Version:      $KUBERNETES_VERSION"
    echo "  Environment:      $ENVIRONMENT"
}

# Parse command line arguments
case "${1:-}" in
    -h|--help)
        show_usage
        exit 0
        ;;
    -i|--info)
        show_config
        exit 0
        ;;
    "")
        main
        ;;
    *)
        print_error "Unknown option: $1"
        show_usage
        exit 1
        ;;
esac
