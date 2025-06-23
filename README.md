# Build a cluster for the lab exercises using the Hashicorp Terraform. 

## Understanding Terraform config files
- The providers.tf file configures the Terraform providers that will be needed to build the infrastructure. In our case, we use the aws, kubernetes and helm providers:
- The main.tf file sets up some Terraform data sources so we can retrieve the current AWS account and region being used, as well as some default tags:
- The vpc.tf configuration will make sure our VPC infrastructure is created:
- Finally, the eks.tf file specifies our EKS cluster configuration, including a Managed Node Group


## Creating the workshop environment with Terraform
For the given configuration, terraform will create the Workshop environment with the following:

- Create a VPC across three availability zones
- Create an EKS cluster
- Create an IAM OIDC provider
- Add a managed node group named default
- Configure the VPC CNI to use prefix delegation


### Steps
Create end to end DevOps project for Microservice
- Configure Service Account
- Configure Service, Deployment, Scaling, Service Discovery
- Deploy
- Expose the project using service type, 
- Loadbalancer type, Ingress, Ingress controller


-- create pod through Deployment (used Deployment for Scaling and healing)
-- Service resource for Service discovery
-- Ingress incoming traffic to pod

- > # Pod: has containers (microservice applications)
- - > # Deployment - used to deploy pods for Auto Scaling and Auto Healing capabilities
- - - - > # Service Resource - used to help pods for Service descovery
- - - - - - - > # Ingress - to customize incoming traffic to our pod.