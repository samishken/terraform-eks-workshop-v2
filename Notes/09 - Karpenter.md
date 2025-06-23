# Karpenter

### Implement Karpenter
https://www.cloudnativedeepdive.com/implementing-karpenter-in-eks-from-start-to-finish/
https://www.youtube.com/watch?v=cHaQwKjK0iU

# Karpenter for EKS

## 🛠️ What is Karpenter?
- **Karpenter** is an open-source Kubernetes cluster autoscaler designed to optimize the provisioning of compute resources.
- It automatically launches new nodes in response to unschedulable pods and scales down nodes when they are no longer needed.
- Karpenter is designed to work with **Amazon EKS** and other Kubernetes clusters.

---

## 🚀 Key Features
- **Dynamic Scaling**: Automatically provisions nodes based on workload requirements.
- **Cost Optimization**: Selects the most cost-effective instance types for workloads.
- **Fast Provisioning**: Reduces the time required to launch new nodes compared to traditional autoscalers.
- **Customizable Node Configuration**: Supports custom labels, taints, and instance types.

---

## 📦 How Karpenter Works
1. **Detect Unschedulable Pods**:
   - Karpenter monitors the cluster for pods that cannot be scheduled due to insufficient resources.
2. **Provision Nodes**:
   - It dynamically provisions new nodes with the required resources to schedule the pods.
3. **Scale Down**:
   - Karpenter terminates underutilized nodes to reduce costs.

---

## 🛠️ Prerequisites for Karpenter in EKS
1. **Amazon EKS Cluster**:
   - Ensure you have an EKS cluster running.
2. **IAM Role**:
   - Create an IAM role with permissions for Karpenter to manage EC2 instances.
3. **Kubernetes Version**:
   - Karpenter requires Kubernetes 1.19 or later.
4. **Helm**:
   - Install Helm for deploying Karpenter.

---

## 🔧 Installation Steps
### Step 1: Install Karpenter
- Use Helm to install Karpenter:
```bash
helm repo add karpenter https://charts.karpenter.sh
helm repo update
helm install karpenter karpenter/karpenter \
  --namespace karpenter \
  --create-namespace \
  --set clusterName=<your-cluster-name> \
  --set clusterEndpoint=<your-cluster-endpoint> \
  --set aws.defaultInstanceProfile=<instance-profile-name>
  ```

### Step 2: Configure Karpenter
- Apply a Provisioner resource to define how Karpenter should provision nodes:
```
apiVersion: karpenter.sh/v1alpha5
kind: Provisioner
metadata:
  name: default
spec:
  requirements:
    - key: "kubernetes.io/arch"
      operator: In
      values: ["amd64", "arm64"]
  limits:
    resources:
      cpu: "1000"
      memory: "1000Gi"
  provider:
    instanceTypes: ["m5.large", "m5.xlarge"]
```
---
📊 Benefits of Using Karpenter
- Improved Efficiency: Automatically scales resources based on workload needs.
- Reduced Costs: Optimizes instance selection to minimize costs.
- Simplified Management: Reduces the complexity of managing node pools.

---
🛠️ Example Use Case
Scenario:
- Your EKS cluster has workloads with varying resource requirements.
- During peak traffic, pods cannot be scheduled due to insufficient resources.
- Karpenter automatically provisions new nodes to handle the increased workload and scales down nodes during off-peak hours.
