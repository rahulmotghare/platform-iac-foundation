# Platform IaC Foundation
Reproducible AWS infrastructure built with Terraform: a multi-AZ VPC and an
Amazon EKS (Kubernetes) cluster, with remote state in S3 and state locking
via DynamoDB.
## Architecture
![architecture](screenshots/architecture.png)
<!-- (add a diagram here later — see note below) -->
## What this builds
- A VPC across 2 availability zones (public + private subnets, single NAT
gateway)
- An EKS cluster (Kubernetes 1.33) with a managed node group (2x t3.medium)
- Modern EKS Access Entry authentication
- Remote Terraform state (S3) with locking (DynamoDB)
## How to run it
```bash
cd bootstrap && terraform init && terraform apply # one-time: creates state
backend
cd ..
terraform init
terraform plan
terraform apply # builds the cluster (~15
min)
aws eks update-kubeconfig --name platform-dev --region us-east-1
kubectl get nodes # verify
terraform destroy # tear down when done
