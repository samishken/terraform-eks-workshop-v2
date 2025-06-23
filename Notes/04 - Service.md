# Service
- needed for service discovery

### Service Discovery Problem (use case)
- If we have frontend and backend containers.  Both of them have ip addressess
- Backend container went down. Restart mechanism restarted the container.
- But when the container restarts the IP address for the backend changed.
- Now frontend container stopped connecting to backend container.
- Need to be adjusted manually (hard code the new IP address)

### K8s address the above problem using Service
- With Service (labels and selectors) frontend and backend can communicate.
- If the IP address changes many times, as long as `labels and selectors` are set, we'll resolve the communication issue.

### For external users
- Service can provide external url so that users can connect to pod.
- Three types of Services (ClusterIP, NodePort, LoadBalancer)

# Kubernetes Service and Service Discovery

## 🛠️ What is a Service?
- A **Service** in Kubernetes is an abstraction that defines a logical set of Pods and a policy to access them.
- It provides **stable networking** for Pods, even if the underlying Pods are replaced or scaled.

---

## 🔍 Service Discovery
- **Service Discovery** allows applications to find and communicate with each other within the cluster.
- Kubernetes automatically assigns a **DNS name** to each Service, enabling Pods to access other Services using their names.

---

## 🧱 Types of Services
| Service Type       | Description                                                                 |
|--------------------|-----------------------------------------------------------------------------|
| **ClusterIP**      | Default type. Exposes the Service within the cluster using an internal IP. |
| **NodePort**       | Exposes the Service on each node's IP at a static port.                    |
| **LoadBalancer**   | Exposes the Service externally using a cloud provider's load balancer.     |
| **ExternalName**   | Maps the Service to an external DNS name.                                  |

---

## 📊 Key Features
- **Stable IP Address**: Services provide a consistent IP address for accessing Pods.
- **Load Balancing**: Distributes traffic across multiple Pods.
- **DNS Integration**: Automatically creates DNS records for Services.

---

## 🚀 Example: ClusterIP Service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:  # Selector used to identify ("my-app" is the label).
    app: my-app   # This service will look for pods with "my-app" label.
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080  ## should be present in Deployment
  type: ClusterIP # Fully Qualified Domain Name FQDN
  ```
---
## 🔍 Selector and Labels in Kubernetes Service Resources

### **What are Labels?**
- **Labels** are key-value pairs attached to Kubernetes objects (e.g., Pods, Services, Deployments).
- They are used to organize and identify objects in a cluster.
- Labels are **arbitrary** and can be customized based on your application's needs.

#### Example of Labels:
```yaml
metadata:
  labels:
    app: my-app
    environment: production
```

### we have many microservices, How one service is connected to another?
- For example: if Shipping Service has to connect to the Quote service, in the environment Variable of Shipping pod (deployment resource), I have the service name of the Quote Service and that service name with the concept of service discovery in Kubernetes, it connects Shipping to Quote service.  So typically it happens through environment variables or config maps.  Using environment variables is quite common.

### How One Service is Connected to Another?

In Kubernetes, services communicate with each other using **service discovery** mechanisms. This ensures that applications can dynamically find and connect to other services without relying on hardcoded IP addresses or manual configuration.

---

#### Example: Connecting Shipping Service to Quote Service
- **Scenario**: 
  - You have two services: **Shipping Service** and **Quote Service**.
  - The **Shipping Service** needs to send requests to the **Quote Service**.

- **Problem**:
  - Pods in Kubernetes are ephemeral, meaning their IP addresses can change when they are restarted or rescheduled.
  - If the **Quote Service** pod's IP changes, the **Shipping Service** would lose connectivity unless manually updated.

- **Solution**:
  Kubernetes solves this problem using **Service Discovery**:
  - A **Service** is created for the **Quote Service**.
  - The **Shipping Service** can use the **DNS name** of the Quote Service to connect to it.
  - Example DNS name: `quote-service.default.svc.cluster.local`.

---

#### How It Works:
1. **Environment Variables**:
   - Kubernetes automatically injects environment variables into the pods for each Service.
   - Example:
     - `QUOTE_SERVICE_SERVICE_HOST`: Contains the IP address of the Quote Service.
     - `QUOTE_SERVICE_SERVICE_PORT`: Contains the port number of the Quote Service.
   - The **Shipping Service** can use these environment variables to connect to the Quote Service dynamically.

2. **DNS-Based Service Discovery**:
   - Kubernetes assigns a DNS name to each Service.
   - The **Shipping Service** can use the DNS name (e.g., `quote-service.default.svc.cluster.local`) to connect to the Quote Service.
   - This DNS name remains stable even if the underlying pods are replaced or rescheduled.

3. **ConfigMaps**:
   - Alternatively, you can use **ConfigMaps** to store the service name or connection details.
   - The **Shipping Service** reads the configuration from the ConfigMap to connect to the Quote Service.

---

#### Example: Environment Variable Usage
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: shipping-service
spec:
  replicas: 2
  template:
    metadata:
      labels:
        app: shipping-service
    spec:
      containers:
      - name: shipping-container
        image: shipping-service:latest
        env:
        - name: QUOTE_SERVICE_HOST   ### this will connect to Quote service
          value: "quote-service.default.svc.cluster.local"
        - name: QUOTE_SERVICE_PORT
          value: "8080"
```

### Service Types
- ClusterIP
- NodePort
- LoadBalancer
- When we create Loadbalancer service type, the API servier, will use CCM (Cloud Controller Manager) to create external IP address.  CCM will also request AWS to create LoadBalancer.  
- FQDN will create the IP address within the loadbalancer.
