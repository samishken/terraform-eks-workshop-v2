# 🛡️ What is High Availability (HA) in EKS?

**Vertical Pod Autoscaler** - CPU/memory requests/limits for each pod.

**High Availability (HA)** means ensuring your system or application is **resilient to failures** and can continue operating **without downtime**, even if parts of the infrastructure fail.

In the context of **Amazon EKS (Elastic Kubernetes Service)**, HA ensures that:
- Your Kubernetes **control plane is reliable**
- Your **worker nodes and pods** can survive AZ or node failures
- Your **application traffic and data** remain available

---

## 🏗️ Components of High Availability in EKS

### 1. **Control Plane HA**
- **EKS control plane** is managed by AWS and is **highly available by default**.
- It runs across **multiple Availability Zones (AZs)** in a region.
- ✅ **You don’t need to manage this layer**.

---

### 2. **Node Group HA**
- Use **Managed Node Groups** or **Fargate** in **at least 2–3 AZs**.
- Use **Auto Scaling Groups** for elasticity and redundancy.
- Example with `eksctl`:
  ```bash
  eksctl create nodegroup \
    --name app-ng \
    --cluster my-cluster \
    --region us-east-1 \
    --zones us-east-1a,us-east-1b,us-east-1c \
    --nodes 3

- Karpenter: can be part of your High Availability (HA) strategy in EKS, especially at the node layer.
#### What is Karpenter?
- Karpenter is an open-source, high-performance Kubernetes node autoscaler created by AWS. It automatically:
- Launches new nodes when pods are unschedulable
- Scales down unused nodes to save costs
- Optimizes for speed, availability, and cost-efficiency


# 🔒 High Availability (HA) Solutions in EKS

Ensuring **High Availability (HA)** in Amazon EKS involves multiple layers of redundancy and fault tolerance, including infrastructure, workloads, networking, and storage.

Below are the key categories and solutions used to achieve HA in EKS.

---

## 1. ☁️ Control Plane HA (Built-in)

- **EKS Control Plane** is highly available **by default**.
- Deployed across **multiple Availability Zones (AZs)**.
- AWS automatically manages HA, failover, and backups.

✅ **You don’t need to manage this layer.**

---

## 2. 🖥️ Node Layer HA

### ✅ **Karpenter**
- Dynamic autoscaler for provisioning EC2 nodes based on real-time demand.
- Launches nodes in multiple AZs automatically.
- Supports On-Demand and Spot for cost-optimized HA.

### ✅ **Managed Node Groups**
- Create node groups in **multiple AZs**.
- Set up **Auto Scaling Groups (ASGs)** for resilience.
- Can use **mixed instance types** for added fault tolerance.

---

## 3. 📦 Pod & Workload HA

### ✅ **Replica Sets / Deployments**
- Run multiple replicas of each workload.
- Spread across multiple nodes and AZs.

### ✅ **PodAntiAffinity**
- Ensure pods don’t land on the same node using:
  ```yaml
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      - topologyKey: "kubernetes.io/hostname"
  ```

### ✅ **PodDisruptionBudgets (PDBs)**
- Define how many pods must remain available during voluntary disruptions.

### ✅ **Liveness and Readiness Probes**
- Automatically restart or remove unhealthy pods from service routing.

---

## 4. ⚖️ Networking & Load Balancing HA

### ✅ **AWS Load Balancer Controller (ALB/NLB)**
- Deploy **multi-AZ Application Load Balancers (ALBs)** or **Network Load Balancers (NLBs)**.
- Automatically routes traffic to healthy pods across AZs.

### ✅ **Kubernetes Services**
- Internal load balancing to spread traffic across pod replicas.
- Use `ClusterIP`, `NodePort`, or `LoadBalancer` types appropriately.

---

## 5. 💾 Storage HA

### ✅ **Amazon EBS (Zonal Storage)**
- Use for StatefulSets with EBS CSI driver.
- Suitable for HA within a single AZ.

### ✅ **Amazon EFS (Multi-AZ Storage)**
- Shared file system usable by multiple pods across AZs.
- Ideal for multi-reader workloads or distributed systems.

### ✅ **S3/Object Storage**
- Use for storing logs, backups, or object-based application state.

---

## 6. 📈 Autoscaling HA

### ✅ **Horizontal Pod Autoscaler (HPA)**
- Scales pods based on CPU, memory, or custom metrics.


### ✅ **Cluster Autoscaler or Karpenter**
- Scales node groups or provisions new nodes automatically when pods are pending.

---

## 7. 🧠 Application-Level HA

- Use **leader election** for apps like Kafka, Redis Sentinel, etc.
- Implement **replication**, **failover**, and **self-healing** logic within the app layer.
- Monitor state via health checks and readiness probes.

---

## ✅ Summary

| Layer             | HA Solution                                |
|-------------------|---------------------------------------------|
| Control Plane     | EKS managed multi-AZ control plane          |
| Node Scaling      | Karpenter, Managed Node Groups              |
| Workload          | Replicas, PDBs, Probes, Anti-Affinity       |
| Networking        | ALB/NLB via AWS Load Balancer Controller    |
| Storage           | EBS, EFS, S3                                |
| Auto-healing      | HPA, Cluster Autoscaler, Karpenter          |
| App Logic         | Leader election, internal retries/failover  |

---

> High Availability is a **layered strategy** — combining Kubernetes capabilities with AWS infrastructure and application-level design.