provider "kubernetes" {
  host = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token = data.aws_eks_cluster_auth.cluster.token
}

provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {
   state = "available"
}

# Data source for EKS cluster authentication
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name  # This should be the name of your EKS cluster
}

locals {
  cluster_name = var.clusterName
}

##