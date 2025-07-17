# AKS Minimal Cluster - Feature Selection Guide

## 📋 Decision Matrix: Which Features to Enable?

### 🎯 **Use Case Based Feature Selection**

| Use Case | Monitoring | Workload Identity | OS Disk Type | Estimated Cost | When to Use |
|----------|------------|-------------------|--------------|----------------|-------------|
| **Learning/Lab** | ❌ Disabled | ❌ Disabled | Ephemeral | $45-55/month | Learning AKS, tutorials |
| **Development** | ✅ Enabled | ❌ Disabled | Ephemeral | $65-75/month | App development, testing |
| **Pre-Production** | ✅ Enabled | ✅ Enabled | Managed | $85-95/month | Integration testing |
| **Production** | ✅ Enabled | ✅ Enabled | Managed | $150-200/month | Live workloads |

### 💰 **Cost Impact Analysis**

#### **Log Analytics & OMS Agent (ama-logs)**
```json
// Truly minimal (learning)
{
  "enableMonitoring": false  // Saves $20-30/month
}

// Development with observability
{
  "enableMonitoring": true   // Adds monitoring but increases cost
}
```

**Cost Breakdown:**
- **Pod Overhead**: OMS agent uses 100m CPU + 200Mi memory per node
- **Log Ingestion**: $2-5 per GB (typically 2-10GB/month for dev clusters)
- **Storage**: Log Analytics workspace storage costs
- **Total Impact**: $15-35/month additional cost

#### **OS Disk Type Comparison**

| Disk Type | Cost | Performance | Use Case | Trade-offs |
|-----------|------|-------------|----------|------------|
| **Ephemeral** | ✅ Lower | ✅ Faster | Dev/Test | ❌ Data loss on restart |
| **Managed** | ❌ Higher | ❌ Slower | Production | ✅ Data persistence |

**Ephemeral Disk Benefits:**
- **Cost**: 30-40% cheaper (no additional storage charges)
- **Performance**: Uses local VM SSD cache (faster I/O)
- **Simplicity**: No disk management overhead

**Ephemeral Disk Limitations:**
- **Data Loss**: Node restart = data loss (acceptable for stateless workloads)
- **VM Requirements**: Requires sufficient local storage on VM

### 🔧 **Recommended Configurations**

#### **Truly Minimal (Learning/Lab)**
```bicep
// Parameters for absolute minimum cost
{
  "nodeVmSize": "Standard_B2s",           // Cheapest option
  "nodeCount": 1,                         // Single node
  "enableMonitoring": false,              // No log analytics
  "enableWorkloadIdentity": false,        // No additional webhooks
  "osDiskType": "Ephemeral"              // Cheapest storage
}
```
**Monthly Cost**: ~$45-55 USD

#### **Development Ready**
```bicep
// Parameters for development with basic observability
{
  "nodeVmSize": "Standard_D2s_v3",        // Better performance
  "nodeCount": 1,                         // Single node
  "enableMonitoring": true,               // Log analytics enabled
  "enableWorkloadIdentity": false,        // Keep simple
  "osDiskType": "Ephemeral"              // Fast and cheap
}
```
**Monthly Cost**: ~$65-75 USD

#### **Production Ready**
```bicep
// Parameters for production workloads
{
  "nodeVmSize": "Standard_D2s_v3",        // Reliable performance
  "nodeCount": 3,                         // High availability
  "enableMonitoring": true,               // Full observability
  "enableWorkloadIdentity": true,         // Secure pod identity
  "osDiskType": "Managed"                // Data persistence
}
```
**Monthly Cost**: ~$150-200 USD

### 📊 **Resource Impact Comparison**

#### **System Pod Count by Configuration**

| Configuration | System Pods | CPU Usage | Memory Usage |
|---------------|-------------|-----------|--------------|
| Truly Minimal | 8-10 pods | ~300m | ~500Mi |
| With Monitoring | 12-14 pods | ~450m | ~750Mi |
| Full Features | 15-18 pods | ~600m | ~1000Mi |

#### **Feature-by-Feature Resource Impact**

**Log Analytics (OMS Agent):**
- **Pods Added**: 1 per node (ama-logs)
- **Resource Usage**: 100m CPU, 200Mi memory per node
- **Storage**: 1-10GB logs/month depending on verbosity

**Workload Identity:**
- **Pods Added**: 2 webhook pods (azure-wi-webhook-controller-manager)
- **Resource Usage**: 50m CPU, 64Mi memory per webhook
- **Network**: Additional webhook admission controller

### 🎯 **Recommendations for Engineering Manager**

#### **Phase 1: Start Minimal**
```bash
# Deploy with absolute minimum for cost validation
az deployment group create \
  --template-file infra/main.bicep \
  --parameters enableMonitoring=false enableWorkloadIdentity=false osDiskType=Ephemeral
```

#### **Phase 2: Add Observability**
```bash
# Enable monitoring for development insights
az deployment group create \
  --template-file infra/main.bicep \
  --parameters enableMonitoring=true enableWorkloadIdentity=false osDiskType=Ephemeral
```

#### **Phase 3: Production Hardening**
```bash
# Enable all features for production
az deployment group create \
  --template-file infra/main.bicep \
  --parameters enableMonitoring=true enableWorkloadIdentity=true osDiskType=Managed
```

### 📈 **Cost Optimization Tips**

1. **Use Ephemeral Disks** for stateless workloads (30-40% storage savings)
2. **Disable Monitoring** during development phases (saves $20-30/month)
3. **Start with Single Node** and scale based on actual needs
4. **Use B-series VMs** for development (burstable performance at lower cost)
5. **Monitor Log Analytics Usage** - configure retention and sampling

### 🔍 **Monitoring Cost Impact Deep Dive**

The Log Analytics workspace creates several cost components:

**Direct Costs:**
- **Data Ingestion**: $2.76/GB (first 5GB free per workspace)
- **Data Retention**: $0.12/GB/month (beyond 31 days)
- **Alerting**: $0.10 per alert rule per month

**Hidden Costs:**
- **Pod Resources**: Each ama-logs pod reserves CPU/memory from node
- **Network**: Log shipping bandwidth (minimal but measurable)
- **Complexity**: Additional monitoring infrastructure to manage

**Typical Usage:**
- **Dev Cluster**: 2-5GB logs/month = $5-15/month
- **Busy Dev Cluster**: 5-15GB logs/month = $15-45/month

This analysis shows why the template defaults to `enableMonitoring: false` for true cost minimization while providing the option to enable when observability is needed.
