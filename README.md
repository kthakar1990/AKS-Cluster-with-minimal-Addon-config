# Minimal Specification Azure Kubernetes Service (AKS) Cluster

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure-Samples%2Fminimal-aks-cluster%2Fmain%2Finfra%2Fmain.json)
[![Deploy to Azure US Gov](https://aka.ms/deploytoazuregovbutton)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure-Samples%2Fminimal-aks-cluster%2Fmain%2Finfra%2Fmain.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure-Samples%2Fminimal-aks-cluster%2Fmain%2Finfra%2Fmain.json)

This sample demonstrates how to deploy a truly minimal specification Azure Kubernetes Service (AKS) cluster optimized for cost, learning, and development scenarios.

## 🎯 Overview

This template creates the most minimal AKS cluster possible while maintaining basic functionality:

- **Single node** with smallest available VM size
- **Free tier control plane** (no management fees)
- **Basic kubenet networking** (no Azure CNI charges)
- **Minimal add-ons** (optional monitoring and workload identity)
- **Cost-optimized settings** throughout

## 💰 Cost Optimization

- **Estimated monthly cost**: $70-90 USD (VM + storage only)
- **Free control plane**: No management fees
- **Single node**: Minimal compute costs
- **Basic networking**: No premium networking charges
- **Optional monitoring**: Can be disabled to save costs
- **Features**: Essential features only (no premium add-ons)
- **OS**: Linux nodes only
- **Monitoring**: Basic Azure Monitor integration

## Implementation Options

This repository includes four different deployment methods:

### 1. Bicep (Recommended)
Infrastructure as Code using Azure Bicep templates.
```bash
cd bicep
az deployment group create --resource-group <rg-name> --template-file main.bicep
```

### 2. ARM Template
JSON-based ARM template implementation.
```bash
cd arm
az deployment group create --resource-group <rg-name> --template-file azuredeploy.json
```

### 3. Azure CLI
Shell script using Azure CLI commands.
```bash
cd cli
chmod +x deploy.sh
./deploy.sh
```

### 4. Terraform
HashiCorp Terraform implementation.
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

## Prerequisites

- Azure CLI installed and configured
- Appropriate Azure subscription with AKS service available
- Resource group created (or permissions to create one)
- For Terraform: Terraform CLI installed

## Security Considerations

- Uses managed identity for secure authentication
- Implements least privilege access principles
- Enables network security policies
- Configures secure defaults for all components

## Cost Optimization

This minimal spec is designed to minimize costs while providing:
- Essential AKS functionality
- Development and testing capabilities
- Learning environment for Kubernetes

**Estimated Monthly Cost**: ~$50-75 USD (varies by region)

## Resource Allocation Monitoring

After deployment, monitor these key metrics:
- CPU utilization on nodes
- Memory usage patterns
- Pod scheduling efficiency
- Network throughput

## Scaling Considerations

To scale from this minimal spec:
1. Increase node count using `az aks scale`
2. Upgrade node size through node pool updates
3. Add additional node pools for different workload types
4. Enable premium features as needed

## Best Practices Implemented

- **Resource Tagging**: All resources tagged for management
- **Secure Defaults**: Security-first configuration
- **Monitoring**: Essential observability enabled
- **Documentation**: Clear implementation guidance
- **Validation**: Pre-deployment checks included

## Troubleshooting

Common issues and solutions:
- **Quota Limits**: Ensure sufficient compute quota in target region
- **Network Conflicts**: Verify VNET address spaces don't overlap
- **Permissions**: Confirm contributor access to subscription/resource group

## Contributing

To contribute to the AKS samples repository:
1. Fork the [Azure-Samples/aks-store-demo](https://github.com/Azure-Samples/aks-store-demo) repository
2. Create a feature branch for your minimal spec implementation
3. Add your implementation following the existing structure
4. Submit a pull request with detailed description

## Support

For issues related to:
- **AKS Service**: [Azure Support](https://azure.microsoft.com/support/)
- **Implementation**: Create an issue in this repository
- **Documentation**: Contribute improvements via pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
