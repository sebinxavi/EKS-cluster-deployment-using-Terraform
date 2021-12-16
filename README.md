# EKS cluster deployment using Terraform

This blog will walk you through the process of deploying your first kubernetes cluster with infrastructure as code using Terraform and EKS.

## Step 1: Set up Terraform with AWS

The first thing you should do is set up your Terraform. We will create an AWS IAM user for Terraform.

In the AWS console, go to the IAM section and create a user named “EKS-User”. Then add your user to a group named “FullAccessGroup”. Attaches to this group the following rights:

- AdministratorAccess
- AmazonEKSClusterPolicy

Following these steps, AWS will provide you a Secret Access Key and an Access Key ID.

In your own console, create a ~/.aws/credentials file and put your credentials in it:
~~~
[profile1]
aws_access_key_id = <Your access key>
aws_secret_access_key = <Your secret key>
~~~

## Step 2: create provider.tf

~~~
provider "aws" {
  region     = var.region
  shared_credentials_file = "./.aws/credentials"
  profile = "profile1"
}
~~~

## Step 3: Configure remote terraform state file

We will be using S3 backed and and storing the terraform state file in the S3 bucket.
~~~
terraform {
  backend "s3" {
    bucket                  = "terraform-state-bucket-dev1"
    key                     = "eks/terraform.tfstate"
    region                  = "us-east-1"
    shared_credentials_file = "./.aws/credentials"
    profile = "profile1"
  }
}
~~~

## Step 4: Create VPC

This EKS will be deployed in the custom VPC with three public subnets and three private subnets.

~~~
# ---------------------------------------------------
# Creating VPC
# ---------------------------------------------------
resource "aws_vpc" "myvpc" {
    
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.project}-vpc"
  }
    
}


# ---------------------------------------------------
# Attaching InterNet Gateway
# ---------------------------------------------------

resource "aws_internet_gateway" "igw" {
    
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "${var.project}-igw"
  }
}


# ---------------------------------------------------
# Subnet myvpc-public-1
# ---------------------------------------------------

resource "aws_subnet" "public1" {
    
  vpc_id                   = aws_vpc.myvpc.id
  cidr_block               = var.public1_cidr
  availability_zone        = var.public1_az 
  map_public_ip_on_launch  = true
  tags = {
    Name = "${var.project}-public1"
  }
}

# ---------------------------------------------------
# Subent myvpc-public-2
# ---------------------------------------------------

resource "aws_subnet" "public2" {
    
  vpc_id                   = aws_vpc.myvpc.id
  cidr_block               = var.public2_cidr
  availability_zone        = var.public2_az 
  map_public_ip_on_launch  = true
  tags = {
    Name = "${var.project}-public2"
  }
}



# ---------------------------------------------------
# Subnet myvpc-public-3
# ---------------------------------------------------

resource "aws_subnet" "public3" {
    
  vpc_id                   = aws_vpc.myvpc.id
  cidr_block               = var.public3_cidr
  availability_zone        = var.public3_az 
  map_public_ip_on_launch  = true
  tags = {
    Name = "${var.project}-public3"
  }
}

# ---------------------------------------------------
# Subnet myvpc-private-1
# ---------------------------------------------------

resource "aws_subnet" "private1" {
    
  vpc_id                   = aws_vpc.myvpc.id
  cidr_block               = var.private1_cidr
  availability_zone        = var.private1_az 
  map_public_ip_on_launch  = false
  tags = {
    Name = "${var.project}-private1"
  }
}

# ---------------------------------------------------
# Subnet myvpc-private-2
# ---------------------------------------------------

resource "aws_subnet" "private2" {
    
  vpc_id                   = aws_vpc.myvpc.id
  cidr_block               = var.private2_cidr
  availability_zone        = var.private2_az 
  map_public_ip_on_launch  = false
  tags = {
    Name = "${var.project}-private2"
  }
}



# ---------------------------------------------------
# Subnet myvpc-private-3
# ---------------------------------------------------

resource "aws_subnet" "private3" {
    
  vpc_id                   = aws_vpc.myvpc.id
  cidr_block               = var.private3_cidr
  availability_zone        = var.private3_az 
  map_public_ip_on_launch  = false
  tags = {
    Name = "${var.project}-private3"
  }
}


# ---------------------------------------------------
# Creating Elastic Ip
# ---------------------------------------------------

resource "aws_eip" "nat" {
  vpc      = true
  tags     = {
    Name = "${var.project}-eip"
  }
}


# ---------------------------------------------------
# Creating NAT gateway
# ---------------------------------------------------

resource "aws_nat_gateway" "nat" {
    
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public3.id

  tags = {
    Name = "${var.project}-nat"
  }
}

# ---------------------------------------------------
# Public Route table
# ---------------------------------------------------

resource "aws_route_table" "public" {
    
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project}-public"
  }
}


# ---------------------------------------------------
# Private Route table
# ---------------------------------------------------

resource "aws_route_table" "private" {
    
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "${var.project}-private"
  }
}


# ---------------------------------------------------
# Route table Association public1 subnet
# ---------------------------------------------------

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}


# ---------------------------------------------------
# Route table Association public2 subnet
# ---------------------------------------------------

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

# ---------------------------------------------------
# Route table Association public3 subnet
# ---------------------------------------------------

resource "aws_route_table_association" "public3" {
  subnet_id      = aws_subnet.public3.id
  route_table_id = aws_route_table.public.id
}


# ---------------------------------------------------
# Route table Association private1 subnet
# ---------------------------------------------------

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private.id
}


# ---------------------------------------------------
# Route table Association private2 subnet
# ---------------------------------------------------

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private.id
}

# ---------------------------------------------------
# Route table Association private3 subnet
# ---------------------------------------------------

resource "aws_route_table_association" "private3" {
  subnet_id      = aws_subnet.private3.id
  route_table_id = aws_route_table.private.id
}
~~~

## Step 5: Create EKS Cluster

~~~
# ---------------------------------------------------
# Creating EKS Cluster
# ---------------------------------------------------
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
~~~

## Step 6: Deploy all your resources

Once you have finished declaring the variables in terraform.tfvars file, you can deploy the resources using below commands,

- Terraform init: it is used to initialize a working directory containing Terraform configuration files.
- Terraform apply: it is used to apply the changes required to reach the desired state of the configuration.

## Step 7: Check the results

###### Console Output

![alt text](https://i.ibb.co/WDxW9J8/status.png)

After the complete creation, you can go to your AWS account to see your resources:

![alt text](https://i.ibb.co/2MmCkXQ/aws-console2.png)

## Step 8: Interact with your EKS cluster

To interact with your cluster, run this command in your terminal:

~~~
aws eks --region us-east-1 update-kubeconfig --name my-eks
~~~

Next, run kubectl get nodes and you will see the worker nodes from your cluster!

~~~
root@ip-172-31-89-235:~# kubectl get nodes
NAME                             STATUS   ROLES    AGE   VERSION
ip-172-16-149-229.ec2.internal   Ready    <none>   34m   v1.21.5-eks-bc4871b
ip-172-16-173-136.ec2.internal   Ready    <none>   34m   v1.21.5-eks-bc4871b
ip-172-16-85-204.ec2.internal    Ready    <none>   59m   v1.21.5-eks-bc4871b
root@ip-172-31-89-235:~# 
root@ip-172-31-89-235:~# 
root@ip-172-31-89-235:~# kubectl get ns
NAME              STATUS   AGE
default           Active   64m
kube-node-lease   Active   64m
kube-public       Active   64m
kube-system       Active   64m
root@ip-172-31-89-235:~# 
~~~

That concludes this article on using Terraform to deploy Kubernetes clusters on AWS cloud provider. If your cluster is no longer needed, execute the command terraform destroy. Have a great time as you continue your Kubernetes journey!

## Author
Created by [@sebinxavi](https://www.linkedin.com/in/sebinxavi/) - feel free to contact me and advise as necessary!

<a href="mailto:sebin.xavi1@gmail.com"><img src="https://img.shields.io/badge/-sebin.xavi1@gmail.com-D14836?style=flat&logo=Gmail&logoColor=white"/></a>
<a href="https://www.linkedin.com/in/sebinxavi"><img src="https://img.shields.io/badge/-Linkedin-blue"/></a>
