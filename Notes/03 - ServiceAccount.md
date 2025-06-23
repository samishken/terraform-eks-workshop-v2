# Service Account
- Assign pod to Service Accounts
- The pod can be created by any of the controllers (Deployment vs Statefulset vs DeamonSet) It should be assigned to Service Account.

# Why Assign Pods to Service Accounts in EKS?

In **Amazon EKS**, assigning a **Kubernetes Service Account** to your pods is a best practice, mainly because of **IAM Roles for Service Accounts (IRSA)**.

---

## Why assign pods to a Service Account in EKS?

### 1. Fine-Grained AWS Permissions with IRSA

- EKS lets you **associate an AWS IAM role with a Kubernetes Service Account**.
- Pods that use this service account get **temporary AWS credentials scoped to that IAM role**.
- This way, **each pod can have its own AWS permissions**, following the **principle of least privilege**.

### 2. Security Isolation

- Instead of giving your worker nodes broad AWS permissions (via node IAM roles), you **limit what each pod can do**.
- This reduces risk if a pod is compromised.

### 3. Simplified Credential Management

- Pods automatically receive AWS credentials via environment variables or mounted tokens.
- No need to manage static AWS keys inside containers.

---

## How it works:

1. Create an IAM role with a trust policy allowing EKS service accounts.
2. Create a Kubernetes Service Account annotated with the IAM role ARN.
3. Deploy your pod specifying that Service Account.
4. The pod assumes the IAM role when accessing AWS APIs (e.g., S3, DynamoDB).

---

### Example annotation on Service Account:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-app-sa
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::123456789012:role/my-app-role

```
- There's always a default Service Account, in case if we don't assign pods with custom service account.
- It comes with default permissions.
- 
- Service Account should be assigned to a Role,  if we want a Pod to talk to k8s api, fetch a data - 

## Steps to create Service Account in AWS
- Create Role with necessary permissions
- Bind the Role to Service Account using role binding or cluster role binding.


## How many Service Accounts per microservice project?

#### When one Service Account might be enough:
- Your microservices share the same AWS permissions (e.g., all need full S3 read/write).
- You want to keep things simple and don’t require strict permission boundaries between pods.
- Your app is small and security risks from over-permission are low.

#### When you should create multiple Service Accounts:
- Each microservice has different AWS permission needs (e.g., one needs DynamoDB access, another only S3 read).
- You want to follow the principle of least privilege to minimize risk.
- You want better auditability and control over which service accessed what.
- You have sensitive or critical components needing isolated permissions.
- You want to rotate or update IAM roles independently per microservice.

#### Best practice recommendation:
- Create one Service Account per microservice (or per logical permission boundary).
- Annotate each with the appropriate IAM role with just the permissions that service needs.
- This gives you fine-grained security and easier maintenance.

