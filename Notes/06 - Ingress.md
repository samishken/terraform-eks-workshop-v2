# Ingress

### AWS Load Balancer Controller
- If we select to go with ALB as loadbalancer, first we need to install AWS Load Balancer Controller 	
- AWS Load Balancer Controller reads that YAML file understands what is the exact requirement and it creates loadbalancer accordingly.
- AWS Load Balancer Controller. (It won't come by default.)
- In our case we need to create ALB controller
- ALB controller will look at the Ingress resource (yaml file) will create Loadbalancer
- AWS Load Balancer Controller is a controller to help manage Elastic Load Balancers for a Kubernetes cluster.
- The controller can provision the following resources:
- - - - - An AWS Application Load Balancer when you create a Kubernetes Ingress.
- - - - - An AWS Network Load Balancer when you create a Kubernetes Service of type LoadBalancer.
- Application Load Balancers work at L7 of the OSI model, allowing you to expose Kubernetes service using ingress rules, and supports external-facing traffic. Network load balancers work at L4 of the OSI model, allowing you to leverage Kubernetes Services to expose a set of pods as an application network service.
- The controller enables you to simplify operations and save costs by sharing an Application Load Balancer across multiple applications in your Kubernetes cluster.


### Installing ALB Controller
- Create IAM role with necessary policies
- Create OIDC
- Associate OIDC provider with cluster

### Disadvantages of using LoadBalancer service type
- It's not declarative
- Not cost effective because we have to create multiple LoadBalancer types.  That's expensive
- Cluster must have Cloud Controller Manager (CCM)
- By default CCM only create ALB. It cannot use Nginx, f5, Traffic Envoy

## What is the Difference Between LoadBalancer Service Type and Ingress?

### **LoadBalancer Service Type**
- **Purpose**: Exposes a Kubernetes Service externally using a cloud provider's load balancer.
- **How It Works**:
  - Creates a dedicated load balancer (e.g., AWS ELB or ALB) for each Service.
  - Routes external traffic directly to the pods backing the Service.
- **Advantages**:
  - Simple to set up for exposing individual Services.
  - Provides direct access to pods via the load balancer.
- **Disadvantages**:
  - **Not Declarative**: Each Service requires a separate load balancer, which is managed individually.
  - **Costly**: Creating multiple load balancers for different Services can be expensive.
  - **Limited Flexibility**: By default, cloud providers may only support specific types of load balancers (e.g., ALB in AWS).
  - **No Centralized Routing**: Each Service has its own load balancer, making routing management more complex.

---

### **Ingress**
- **Purpose**: Provides centralized routing for multiple Services using a single entry point.
- **How It Works**:
  - Uses an **Ingress Controller** (e.g., NGINX, AWS ALB, Traefik) to manage routing rules.
  - Routes external traffic to different Services based on path or host-based rules.
- **Advantages**:
  - **Declarative**: Routing rules are defined in a single Ingress resource.
  - **Cost Effective**: Uses a single load balancer for multiple Services, reducing costs.
  - **Flexible**: Supports custom Ingress Controllers (e.g., NGINX, Traefik, Envoy) for advanced routing.
  - **Centralized Management**: Simplifies routing by consolidating rules in one place.
- **Disadvantages**:
  - Requires an **Ingress Controller** to be deployed in the cluster.
  - More complex to set up compared to LoadBalancer Service type.

---

### **Key Differences**
| Feature                     | LoadBalancer Service Type         | Ingress                              |
|-----------------------------|------------------------------------|--------------------------------------|
| **Purpose**                 | Exposes individual Services       | Centralized routing for multiple Services |
| **Cost**                    | Expensive (multiple load balancers) | Cost-effective (single load balancer) |
| **Routing**                 | Direct routing to pods            | Path-based or host-based routing     |
| **Declarative**             | No                                | Yes                                  |
| **Flexibility**             | Limited to cloud provider's load balancer | Supports custom Ingress Controllers |
| **Complexity**              | Simple                            | Requires Ingress Controller setup    |

---

### **When to Use Each**
- **LoadBalancer Service Type**:
  - Best for simple setups where you need to expose a single Service externally.
  - Suitable for small-scale applications or testing environments.

- **Ingress**:
  - Ideal for production environments with multiple Services.
  - Useful when you need advanced routing, cost optimization, and centralized management.

Let me know if you need further clarification or examples!


### Advantages of using Ingress
- It's created declaratively.  LoadBalancer can be modified, updated, add can use labels and annotations
- Cost effective.  One loadbalancer is enough for multiple microservices. Use path or port based routing.
- Not dependent on Cloud Controller Manager (CCM).  For non cloud we can use reverse proxy.
- Flexible to use multiple loadbalancer methods.  Nginx, F5, Traffic Envoy

### Understanding Ingess and Ingress controller


### Deploy the ALB Ingress controller


### Ingress
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /service1
        pathType: Prefix
        backend:
          service:
            name: service1
            port:
              number: 80
      - path: /service2
        pathType: Prefix
        backend:
          service:
            name: service2
            port:
              number: 8080
```


## ✅ How IAM + OIDC + Kubernetes Work Together in EKS
#### 🔧 Setup Flow:
Enable IAM OIDC Provider for your EKS cluster
This allows your EKS cluster to issue tokens that AWS can verify using OIDC.

- Create an IAM Role
This role:

Has a trust policy allowing it to be assumed by tokens coming from the OIDC provider

Is not directly attached to the OIDC provider
→ Instead, it trusts identities from the OIDC provider.

Associate the IAM Role with a Kubernetes Service Account
You annotate the service account like this:

```yaml

metadata:
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::<account-id>:role/<your-role>
```
### 🔁 What Binds Them Together?
##### 🔐 The IAM Role's Trust Policy
It specifies the OIDC provider URL and matches the sub claim from the service account.
Example:
```
{
  "Effect": "Allow",
  "Principal": {
    "Federated": "arn:aws:iam::<account-id>:oidc-provider/oidc.eks.<region>.amazonaws.com/id/<eks-cluster-id>"
  },
  "Action": "sts:AssumeRoleWithWebIdentity",
  "Condition": {
    "StringEquals": {
      "oidc.eks.<region>.amazonaws.com/id/<cluster-id>:sub": "system:serviceaccount:<namespace>:<serviceaccount-name>"
    }
  }
}
```##