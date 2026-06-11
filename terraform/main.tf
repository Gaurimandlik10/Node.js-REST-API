terraform{
    required_providers{
        aws{
            source="hashicorp/aws"
            version="~> 5.0"
        }
    }
    backend "s3" {
     bucket = "proj2-terraform-state-bucket"   # ← create this S3 bucket first
     key    = "restnodejs/terraform.tfstate"
     region = "ap-southeast-2"
  }

}
provider "aws"{
    region="ap-southeast-2"
}
resource "aws_vpc" "proj2_vpc"{
    cidr-block="10.0.0.0/16"
    
    tags={Name = "porj2"}
}
resource "aws_subnet" "proj2_subnet"{
      vpc_id= aws.proj2_vpc.vpc_id
      cidr-block="10.0.0.0/24"

      tags={Name = "proj2_subnet"}
}
resource "aws_ecr_repository" "proj2_ecr"{
    name= "proj2_ecr"
    image_tag_mutability= "MUTABLE"

    image_scanning_configuration {
             scan_on_push = true
            }
}
module "eks"{
     source  = "terraform-aws-modules/eks/aws"
     version = "~> 20.0"

     cluster_name = "proj2_cluster"
     cluster_version = "1.29"

     vpc_id= aws_vpc.proj2_vpc.vpc_id
     subnet_id = [aws_subnet.proj2_subnet.subnet_id]

     enable_cluster_creator_admin_permissions = true

     eks_managed_node_groups = {
        default ={
            instance_types = ["t3.micro"]

            min_size = 1
            max_size = 3
            desired_size = 2

            ami_type = "AL2023_x86_64_STANDARD"

            tags={
                Name = "eks-worker-nodes"
            }
        }
     }
}
