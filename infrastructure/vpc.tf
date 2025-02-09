# Create the VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "eks-vpc"
  cidr = "10.0.0.0/16"  # ✅ This defines the overall IP range for the VPC

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]  # ✅ Private subnets for EKS nodes and CodeBuild
  public_subnets  = ["10.0.101.0/24"]  # ✅ Public subnet for NAT Gateway and ALB

  enable_nat_gateway    = true  # ✅ NAT allows private subnets to access the internet
  single_nat_gateway    = true  # ✅ Use a single NAT Gateway for cost efficiency
  enable_dns_support    = true  # ✅ Enable internal DNS resolution
  enable_dns_hostnames  = true  # ✅ Required for EKS private cluster
}

# Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "Private Subnet IDs"
  value       = module.vpc.private_subnets
}

# Security group for EKS API access
resource "aws_security_group" "eks_api_sg" {
  name        = "eks-api-sg"
  description = "Allow EKS API access from within the VPC"
  vpc_id      = module.vpc.vpc_id

  # Allow inbound traffic to EKS API from CodeBuild
  ingress {
    from_port   = 443  # ✅ HTTPS (EKS API runs on port 443)
    to_port     = 443
    protocol    = "tcp"
    security_groups = [aws_security_group.codebuild_sg.id]  # ✅ Allow CodeBuild access
  }

  # Allow all outbound traffic from EKS API to anywhere
  egress {
    from_port   = 0  # ✅ Allow all outgoing traffic
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # ✅ Allow traffic to any IP
  }

  tags = {
    Name = "eks-api-sg"
  }
}

# Create a VPC Endpoint for EKS API
resource "aws_vpc_endpoint" "eks_api" {
  vpc_id           = module.vpc.vpc_id
  service_name     = "com.amazonaws.us-east-1.eks"  # ✅ Connects private VPC to EKS API
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.eks_api_sg.id]  # ✅ Restrict access to allowed security group
  subnet_ids         = module.vpc.private_subnets  # ✅ Ensure private subnets can reach the EKS API

  private_dns_enabled = true  # ✅ Ensures API calls resolve to the private IP
}


