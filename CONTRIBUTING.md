# Contributing to Azure-Samples/minimal-aks-cluster

This project welcomes contributions and suggestions. Most contributions require you to agree to a Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us the rights to use your contribution.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions provided by the bot. You will only need to do this once across all repos using our CLA.

## Code of Conduct

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## How to Contribute

### Reporting Issues

Please use the [GitHub Issues](https://github.com/Azure-Samples/minimal-aks-cluster/issues) to report bugs or request features.

### Contributing Code

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Update documentation
6. Submit a pull request

### Testing Changes

Before submitting a pull request:

1. Test the Bicep template deployment:
   ```bash
   az deployment group create --resource-group test-rg --template-file infra/main.bicep --parameters infra/main.parameters.json
   ```

2. Verify the cluster works:
   ```bash
   kubectl get nodes
   kubectl get pods --all-namespaces
   ```

3. Clean up test resources:
   ```bash
   az group delete --name test-rg --yes --no-wait
   ```

## Development Guidelines

- Keep the template minimal and cost-optimized
- Document all parameters clearly
- Include examples for common use cases
- Test in multiple Azure regions
- Follow Azure Well-Architected Framework principles

## Questions?

Feel free to reach out via GitHub Issues for any questions about contributing.
