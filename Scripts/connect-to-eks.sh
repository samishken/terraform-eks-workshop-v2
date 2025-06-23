EKS_CLUSTER=eks-workshop

aws eks update-kubeconfig --region us-east-1 --name $EKS_CLUSTER --profile default