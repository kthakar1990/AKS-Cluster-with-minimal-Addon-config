# Deployment Guide - Minimal Spec AKS Cluster

This guide provides step-by-step instructions for deploying the minimal specification AKS cluster using different methods.

## Prerequisites

Before deploying, ensure you have:

- **Azure subscription** with appropriate permissions
- **Azure CLI** installed and configured (`az login`)
- **Resource group** created or permissions to create one
- For Bicep: Azure CLI with Bicep extension
- For Terraform: Terraform CLI installed
- For kubectl management: kubectl installed

## Deployment Methods

### 1. Bicep Deployment (Recommended)

Bicep provides the cleanest Infrastructure as Code experience for Azure resources.

#### Quick Start
```bash
# Clone or navigate to the project directory
cd infra

# Deploy using Azure CLI
az deployment group create \
  --resource-group <your-resource-group> \
  --template-file main.bicep \
  --parameters main.parameters.json

# Or with custom parameters
az deployment group create \
  --resource-group <your-resource-group> \
  --template-file main.bicep \
  --parameters clusterName="my-aks-cluster" environment="test"
```

#### Using Azure Developer CLI (azd)
```bash
# Initialize azd (if not already done)
azd init

# Deploy infrastructure and any services
azd up
```

### 2. ARM Template Deployment

Traditional JSON-based ARM template deployment.

```bash
cd arm

# Deploy the ARM template
az deployment group create \
  --resource-group <your-resource-group> \
  --template-file azuredeploy.json \
  --parameters azuredeploy.parameters.json
```

### 3. Azure CLI Script

Automated deployment using Azure CLI commands.

```bash
cd cli

# Make the script executable (Linux/macOS)
chmod +x deploy.sh

# Run the deployment script
./deploy.sh

# Or with custom environment variables
CLUSTER_NAME="my-cluster" LOCATION="westus2" ./deploy.sh
```

**Windows PowerShell:**
```powershell
# Convert the bash script logic or use WSL
wsl ./deploy.sh
```

### 4. Terraform Deployment

HashiCorp Terraform infrastructure deployment.

```bash
cd terraform

# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Review deployment plan
terraform plan

# Apply the configuration
terraform apply -auto-approve

# View outputs
terraform output
```

## Post-Deployment Steps

### 1. Configure kubectl Access

```bash
# Get cluster credentials
az aks get-credentials --resource-group <resource-group> --name <cluster-name>

# Verify connectivity
kubectl cluster-info
kubectl get nodes
```

### 2. Verify Cluster Health

```bash
# Check node status
kubectl get nodes -o wide

# Check system pods
kubectl get pods --namespace=kube-system

# Check cluster events
kubectl get events --sort-by=.metadata.creationTimestamp
```

### 3. Deploy Sample Application

```bash
# Deploy nginx test application
kubectl create deployment nginx --image=nginx:latest

# Expose the deployment
kubectl expose deployment nginx --port=80 --type=LoadBalancer

# Check service status
kubectl get services
```

### 4. Monitor Resource Usage

```bash
# View node resource usage
kubectl top nodes

# View pod resource usage
kubectl top pods --all-namespaces
```

## Customization Options

### Environment Variables (CLI Script)

- `CLUSTER_NAME`: Name of the AKS cluster
- `RESOURCE_GROUP`: Resource group name
- `LOCATION`: Azure region
- `NODE_COUNT`: Number of nodes (1-3)
- `NODE_VM_SIZE`: VM size (Standard_B2s recommended)
- `KUBERNETES_VERSION`: K8s version
- `ENVIRONMENT`: Environment tag

### Parameters (Bicep/ARM)

Modify the parameters files to customize:
- Cluster name and DNS prefix
- Node count and VM size
- Kubernetes version
- Environment tags

### Variables (Terraform)

Create a `terraform.tfvars` file:
```hcl
cluster_name = "my-minimal-aks"
location     = "West US 2"
node_count   = 2
environment  = "production"
```

## Cost Optimization Features

This minimal spec includes several cost optimizations:

- **Free Tier AKS**: No charge for the control plane
- **Single Node**: Minimal node count (can be scaled up)
- **Standard_B2s VMs**: Cost-effective burstable VMs
- **Kubenet Networking**: Simpler, less expensive networking
- **Basic Monitoring**: Essential observability without premium features
- **No Premium Add-ons**: Disabled expensive features like Azure Policy

## Scaling Considerations

To scale from this minimal configuration:

### Horizontal Scaling
```bash
# Scale node count
az aks scale --resource-group <rg> --name <cluster> --node-count 3

# Enable auto-scaling
az aks update --resource-group <rg> --name <cluster> --enable-cluster-autoscaler --min-count 1 --max-count 5
```

### Vertical Scaling
```bash
# Add new node pool with larger VMs
az aks nodepool add \
  --resource-group <rg> \
  --cluster-name <cluster> \
  --name largerpool \
  --node-count 1 \
  --node-vm-size Standard_D4s_v3
```

### Add Premium Features
```bash
# Enable Azure Policy
az aks enable-addons --addons azure-policy --name <cluster> --resource-group <rg>

# Enable Application Gateway Ingress Controller
az aks enable-addons --addons ingress-appgw --name <cluster> --resource-group <rg> --appgw-subnet-cidr "10.2.0.0/16"
```

## Troubleshooting

### Common Issues

1. **Insufficient Quota**
   ```bash
   # Check compute quota
   az vm list-usage --location <location> -o table
   ```

2. **Network Conflicts**
   - Ensure CIDR ranges don't overlap with existing VNets
   - Default pod CIDR: 10.244.0.0/16
   - Default service CIDR: 10.0.0.0/16

3. **Permission Issues**
   ```bash
   # Check current user permissions
   az role assignment list --assignee $(az account show --query user.name -o tsv)
   ```

### Validation Commands

```bash
# Validate Bicep template
az bicep build --file main.bicep

# Validate ARM template
az deployment group validate --resource-group <rg> --template-file azuredeploy.json

# Terraform validation
terraform validate
terraform plan
```

## Cleanup

### Remove Resources

**Using Azure CLI:**
```bash
# Delete the entire resource group (if dedicated to this cluster)
az group delete --name <resource-group> --yes --no-wait

# Or delete just the cluster
az aks delete --resource-group <rg> --name <cluster> --yes --no-wait
```

**Using Terraform:**
```bash
terraform destroy -auto-approve
```

**Using azd:**
```bash
azd down
```

## Security Considerations

Even in a minimal spec, security best practices are maintained:

- **RBAC Enabled**: Role-based access control
- **Managed Identity**: Secure authentication without secrets
- **Workload Identity**: Modern pod identity solution
- **Network Security**: Basic network policies available
- **Monitoring**: Security events logged to Azure Monitor

## Next Steps

1. **Production Readiness**: Review [AKS Production Checklist](https://docs.microsoft.com/azure/aks/operator-best-practices-cluster-security)
2. **Monitoring**: Set up [Azure Monitor for containers](https://docs.microsoft.com/azure/azure-monitor/containers/)
3. **Networking**: Consider [Advanced Networking](https://docs.microsoft.com/azure/aks/configure-azure-cni) for production
4. **Security**: Implement [Pod Security Standards](https://docs.microsoft.com/azure/aks/use-pod-security-policies)
5. **Backup**: Configure [Azure Backup for AKS](https://docs.microsoft.com/azure/backup/azure-kubernetes-service-cluster-backup)
