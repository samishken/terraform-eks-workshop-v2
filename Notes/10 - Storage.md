# Storage
Storage on EKS will provide a high level overview on how to integrate two AWS Storage services with your EKS cluster.

### to get familiarity 
- Persistent volumes vs Persistent Volume Claim
- `emptyDir` is ephemeral, tied to the Pod's lifecycle.
- Kubernetes StatefulSets
- EBS CSI Driver
- StatefulSet with EBS Volume
- In kind: Statefulset, `volumeClaimTemplates` field specifies the instructs Kubernetes to utilize Dynamic Volume Provisioning to create a new EBS Volume, a PersistentVolume (PV) and a PersistentVolumeClaim (PVC) all automatically.


Before we dive into the implementation, below is a summary of the two AWS storage services we'll utilize and integrate with EKS:

- `Amazon Elastic Block Store (supports EC2 only)`: a block storage service that provides direct access from EC2 instances and containers to a dedicated storage volume designed for both throughput and transaction-intensive workloads at any scale.
- `Amazon Elastic File System (supports Fargate and EC2)`: a fully managed, scalable, and elastic file system well suited for big data analytics, web serving and content management, application development and testing, media and entertainment workflows, database backups, and container storage. EFS stores your data redundantly across multiple Availability Zones (AZ) and offers low latency access from Kubernetes pods irrespective of the AZ in which they are running.
- `Amazon FSx for NetApp ONTAP (supports EC2 only)`: Fully managed shared storage built on NetApp’s popular ONTAP file system. FSx for NetApp ONTAP stores your data redundantly across multiple Availability Zones (AZ) and offers low latency access from Kubernetes pods irrespective of the AZ in which they are running.
- `Amazon FSx for Lustre (supports EC2 only)`: a fully managed, high-performance scale-out file system optimized for workloads such as machine learning, high-performance computing, video processing, financial modeling, electronic design automation, and analytics. With FSx for Lustre, you can quickly create a high-performance scale-out file system linked to your S3 data repository and transparently access S3 objects as files.
- `Amazon FSx for OpenZFS (supports EC2 only)`: a fully managed, high-performance scale-up file system optimized for workloads requiring the lowest latencies such as self-managed databases, line of business applications, content management systems, package managers, and many others. With FSx for OpenZFS, you can quickly create a highly-available, high-performance scale-up file system with the lowest latencies and lowest per-GB storage pricing of all the AWS file services.
---
It's also very important to be familiar with some concepts about Kubernetes Storage:

Volumes: On-disk files in a container are ephemeral, which presents some problems for non-trivial (not simple, important, significant) applications when running in containers. One problem is the loss of files when a container crashes. The kubelet restarts the container but with a clean state. A second problem occurs when sharing files between containers running together in a Pod. The Kubernetes volume abstraction solves both of these problems. Familiarity with Pods is suggested.

Ephemeral Volumes are designed for these use cases. Because volumes follow the Pod's lifetime and get created and deleted along with the Pod, Pods can be stopped and restarted without being limited to where some persistent volume is available.
Persistent Volumes (PV) is a piece of storage in a cluster that has been provisioned by an administrator or dynamically provisioned using Storage Classes. It's a resource in the cluster just like a node is a cluster resource. PVs are volume plugins like Volumes, but have a lifecycle independent of any individual Pod that uses the PV. This API object captures the details of the implementation of the storage, be that NFS, iSCSI, or a cloud-provider-specific storage system.

Persistent Volume Claim (PVC) is a request for storage by a user. It's similar to a Pod. Pods consume node resources and PVCs consume PV resources. Pods can request specific levels of resources (CPU and Memory). Claims can request specific size and access modes (e.g., they can be mounted ReadWriteOnce, ReadOnlyMany or ReadWriteMany, see AccessModes

Storage Classes provides a way for administrators to describe the "classes" of storage they offer. Different classes might map to quality-of-service levels, or to backup policies, or to arbitrary policies determined by cluster administrators. Kubernetes itself is unopinionated about what classes represent. This concept is sometimes called "profiles" in other storage systems.

Dynamic Volume Provisioning allows storage volumes to be created on-demand. Without dynamic provisioning, cluster administrators have to manually make calls to their cloud or storage provider to create new storage volumes, and then create PersistentVolume objects to represent them in Kubernetes. The dynamic provisioning feature eliminates the need for cluster administrators to pre-provision storage. Instead, it automatically provisions storage when it is requested by users.
---
- We'll first integrate a Amazon EBS volume to be consumed by our MySQL database from the catalog microservice utilizing a statefulset object on Kubernetes. 
- After that we'll integrate our component microservice filesystem to use the Amazon EFS shared file system, providing scalability, resiliency and more control over the files from our microservice.

---
## StatefulSets

Like Deployments, `StatefulSets` manage Pods that are based on an identical container spec. Unlike Deployments, StatefulSets maintain a sticky identity for each of its Pods. These Pods are created from the same spec, but are not interchangeable with each having a persistent identifier that it maintains across any rescheduling event.

If you want to use storage volumes to provide persistence for your workload, you can use a StatefulSet as part of the solution. Although individual Pods in a StatefulSet are susceptible to failure, the persistent Pod identifiers make it easier to match existing volumes to the new Pods that replace any that have failed.

StatefulSets are valuable for applications that require one or more of the following:

- Stable, unique network identifiers
- Stable, persistent storage
- Ordered, graceful deployment and scaling
- Ordered, automated rolling updates

In our ecommerce application, we have a StatefulSet already deployed as part of the Catalog microservice. The Catalog microservice utilizes a MySQL database running on EKS. Databases are a great example for the use of StatefulSets because they require persistent storage. We can analyze our MySQL Database Pod to see its current volume configuration:

```apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: catalog-mysql-ebs
  namespace: catalog
  labels:
    app.kubernetes.io/created-by: eks-workshop
    app.kubernetes.io/team: database
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: catalog
      app.kubernetes.io/instance: catalog
      app.kubernetes.io/component: mysql-ebs
  serviceName: mysql
  template:
    metadata:
      labels:
        app.kubernetes.io/name: catalog
        app.kubernetes.io/instance: catalog
        app.kubernetes.io/component: mysql-ebs
        app.kubernetes.io/created-by: eks-workshop
        app.kubernetes.io/team: database
    spec:
      containers:
        - name: mysql
          image: "public.ecr.aws/docker/library/mysql:8.0"
          imagePullPolicy: IfNotPresent
          env:
            - name: MYSQL_ROOT_PASSWORD
              value: my-secret-pw
            - name: MYSQL_USER
              valueFrom:
                secretKeyRef:
                  name: catalog-db
                  key: username
            - name: MYSQL_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: catalog-db
                  key: password
            - name: MYSQL_DATABASE
              value: catalog
          ports:
            - name: mysql
              containerPort: 3306
              protocol: TCP
          volumeMounts:
            - name: data
              mountPath: /var/lib/mysql
  volumeClaimTemplates:
    - metadata:
        name: data
      spec:
        accessModes: ["ReadWriteOnce"]
        storageClassName: ebs-csi-default-sc
        resources:
          requests:
            storage: 30Gi
```

- In kind: Statefulset, `volumeClaimTemplates` field specifies the instructs Kubernetes to utilize Dynamic Volume Provisioning to create a new EBS Volume, a PersistentVolume (PV) and a PersistentVolumeClaim (PVC) all automatically.



# ⚙️ Kubernetes CSI (Container Storage Interface) Analogy

## 🔌 CSI = The Universal Power Adapter for Storage

Imagine Kubernetes is like an **apartment building (your cluster)**, and your containers are **tenants living in apartments (pods)**. Each tenant needs to **plug in their devices** to use **electricity (storage)**.

But different apartments might use:
- American-style outlets ⚡️
- European-style outlets 🔌
- USB-C or wireless pads 🔋

It would be chaotic to hardwire support for every outlet type into every apartment.

---

## 💡 Enter CSI: A Standardized, Universal Adapter

**CSI (Container Storage Interface)** acts like a **universal power adapter** — a standard interface that allows any tenant (container) to plug into any kind of outlet (storage provider), such as:

- Amazon EBS
- Google Persistent Disks
- Azure Disks
- NFS, Ceph, or local volumes

---

## 🏡 How CSI Helps Stateful Containers

| Benefit | Description |
|---------|-------------|
| ✅ **Plug & Play Storage** | Kubernetes can dynamically attach/detach volumes without knowing vendor specifics. |
| ✅ **Standardized Interface** | Storage vendors implement CSI, so Kubernetes interacts with drivers, not the backend directly. |
| ✅ **Persistent Data** | Supports apps like MySQL, Redis, and Kafka that need their data to survive pod restarts or moves. |

---

## 🧠 TL;DR

> **CSI is like a universal power adapter for container storage.**  
> It gives your stateful apps a consistent, reliable way to plug into storage — no matter the provider — just like tenants plugging into power in any building, anywhere in the world.

---