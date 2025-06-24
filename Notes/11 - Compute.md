# Compute
- In Kubernetes the first aspect we want to ensure we're autoscaling is the EC2 compute infrastructure used to run our pods. This will adjust the number of EC2 instances available to the EKS cluster as worker nodes dynamically as pods are added or removed.
- There are a number of ways to implement compute autoscaling in Kubernetes, and at AWS there are two primary mechanisms available:
- - - - Kubernetes Cluster Autoscaler tool
- - - - Karpenter