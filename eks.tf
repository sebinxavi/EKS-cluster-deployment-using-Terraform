data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "my-eks"
  cluster_version = "1.21"
  subnets         = [aws_subnet.public1.id, aws_subnet.public2.id, aws_subnet.public3.id, aws_subnet.private1.id, aws_subnet.private2.id, aws_subnet.private3.id]
  vpc_id          = aws_vpc.myvpc.id

  node_groups = {
    public = {
      subnets          = [aws_subnet.public1.id, aws_subnet.public2.id, aws_subnet.public3.id]
      desired_capacity = 1
      max_capacity     = 10
      min_capacity     = 1

      instance_type = var.instance_type
      k8s_labels = {
        Environment = "public"
      }
    }
    private = {
      subnets          = [aws_subnet.private1.id, aws_subnet.private2.id, aws_subnet.private3.id]
      desired_capacity = 2
      max_capacity     = 10
      min_capacity     = 1

      instance_type = var.instance_type
      k8s_labels = {
        Environment = "private"
      }
    }
  }

}
