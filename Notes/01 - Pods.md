# Pod 

### Creation types
### Kubernetes Controllers: Deployment vs StatefulSet vs DaemonSet

## 📊 Summary Table

| Feature / Use Case        | **Deployment**                         | **StatefulSet**                          | **DaemonSet**                          |
|---------------------------|----------------------------------------|------------------------------------------|----------------------------------------|
| **Pod Identity**          | Random (e.g., `web-abc123`)            | Stable (e.g., `mysql-0`, `mysql-1`)       | One per node (e.g., `log-agent-node1`) |
| **Pod Storage**           | Shared or ephemeral                    | Each pod has its own **persistent volume** | Usually ephemeral or shared            |
| **Scaling**               | Easy, stateless                        | Ordered, useful for clustered apps        | One per node, scales with node count    |
| **Pod Scheduling**        | Anywhere in the cluster                | Ordered, stable on specific nodes         | Runs **one pod per node**              |
| **Common Use Case**       | Web apps, APIs, stateless microservices | Databases, queues, clustered apps         | Log collectors, node agents, monitoring tools |
| **Rolling Updates**       | Yes                                    | Yes (with caution)                        | Yes, but on all nodes                   |
| **Stable DNS (e.g. `pod-0.service`)** | ❌ No                    | ✅ Yes                                     | ❌ No                                   |

---

## 🧱 Real World Examples

| Use Case                          | Use This       | Why?                                  |
|----------------------------------|----------------|----------------------------------------|
| NGINX or Node.js web app         | Deployment     | Stateless, scalable, random identity is fine |
| MySQL or Kafka with data         | StatefulSet    | Needs stable storage & identity        |
| Prometheus node exporter         | DaemonSet      | Needs to run on **every node**         |
| Logging agent like Fluentd       | DaemonSet      | One instance per node for log collection |
| Redis master-replica setup       | StatefulSet    | Needs unique identities and PVCs       |
| Frontend React app               | Deployment     | Stateless, no special requirements     |

---

## 🚀 TL;DR

| You Need...                                    | Use This     |
|------------------------------------------------|--------------|
| Stateless scaling, generic apps                | Deployment   |
| Stateful workloads with persistent identity    | StatefulSet  |
| One pod per node (node agents, monitoring)     | DaemonSet    |


### Statefulset pod

```apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: redis
spec:
  serviceName: "redis"
  replicas: 1
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
        - name: redis
          image: redis:7
          ports:
            - containerPort: 6379
              name: redis
          volumeMounts:
            - name: redis-data
              mountPath: /data
  volumeClaimTemplates:
    - metadata:
        name: redis-data
      spec:
        accessModes: ["ReadWriteOnce"]
        resources:
          requests:
            storage: 1Gi
        storageClassName: gp2  # Use your default StorageClass if on EKS or leave it blank


apiVersion: v1
kind: Service
metadata:
  name: redis
spec:
  clusterIP: None  # Headless service
  selector:
    app: redis
  ports:
    - port: 6379
      name: redis
```

### Daemonset pod (no replicas field for Daemonset pods)
```apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: busybox-daemon
  labels:
    app: busybox-daemon
spec:
  selector:
    matchLabels:
      app: busybox-daemon
  template:
    metadata:
      labels:
        app: busybox-daemon
    spec:
      containers:
        - name: busybox
          image: busybox
          command: ["sh", "-c", "sleep 3600"]
```

## 🛠️ What is a Pod in Kubernetes?

### **Definition**
- A **Pod** is the smallest deployable unit in Kubernetes.
- It represents a single instance of a running process in your cluster.
- A Pod can contain one or more **containers** that share the same network namespace and storage volumes.

---

### **Pod in Terms of Apps and Containers**
1. **Apps**:
   - Pods are used to run applications in Kubernetes.
   - Each Pod encapsulates an application or a part of an application (e.g., a microservice).
   - Pods provide a consistent environment for running applications, regardless of the underlying infrastructure.

2. **Containers**:
   - Pods act as a wrapper for containers.
   - Containers inside a Pod share:
     - **Networking**: All containers in a Pod share the same IP address and port space.
     - **Storage**: Containers can share volumes mounted in the Pod.
   - Typically, a Pod contains **one container** (the most common use case), but it can have multiple containers that work together (e.g., a sidecar container for logging or monitoring).

---

### **Key Features of Pods**
- **Shared Networking**:
  - All containers in a Pod share the same IP address.
  - Containers communicate with each other using `localhost`.
- **Shared Storage**:
  - Pods can mount shared volumes that are accessible to all containers within the Pod.
- **Lifecycle Management**:
  - Kubernetes manages the lifecycle of Pods, including creation, scheduling, and termination.

---

### **Why Use Pods?**
- **Abstraction**:
  - Pods abstract away the complexity of managing individual containers.
- **Scalability**:
  - Pods can be replicated across nodes to scale applications.
- **Resilience**:
  - Kubernetes ensures Pods are restarted if they fail.

---

### **Pod Use Cases**
| **Use Case**                          | **Pod Type**       | **Why?**                                  |
|---------------------------------------|--------------------|-------------------------------------------|
| Single container app                  | Single-container Pod | Simplest and most common use case.        |
| App with helper container (e.g., logging) | Multi-container Pod | Containers work together in the same Pod. |
| Stateless web app                     | Deployment Pod     | Scalable and ephemeral.                   |
| Stateful database                     | StatefulSet Pod    | Requires persistent storage and stable identity. |
| Node-level monitoring agent           | DaemonSet Pod      | Runs one Pod per node.                    |

---

### **Pod Example**
#### Single-container Pod:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
spec:
  containers:
  - name: nginx
    image: nginx:latest
    ports:
    - containerPort: 80