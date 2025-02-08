resource "aws_security_group" "alb_sg" {
  name        = "fastapi-alb-sg"
  description = "Security group for ALB allowing HTTP traffic"
  vpc_id      = module.vpc.vpc_id  # Ensure it references the correct VPC

  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to all (can restrict for security)
  }

  ingress {
    description = "Allow HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "fastapi-alb-sg"
  }
}

output "alb_security_group_id" {
  value = aws_security_group.alb_sg.id
}

# Create Security Group for EKS Nodes
resource "aws_security_group" "eks_nodes" {
  name        = "eks-node-security-group"
  description = "Security group for EKS worker nodes"
  vpc_id      = module.vpc.vpc_id  # ✅ Attach to our VPC

  # Allow Nodes to Communicate with Each Other
  ingress {
    description = "Allow all traffic between worker nodes"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = module.vpc.private_subnets_cidr_blocks  # ✅ Allow only within our private subnets
  }

  # Allow EKS Control Plane to Communicate with Nodes
  ingress {
    description = "Allow EKS API to communicate with nodes"
    from_port   = 1025
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # ✅ Open to all (Cluster API needs access)
  }

  # Allow Nodes to Reach the Internet (for updates, Docker images, etc.)
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-node-security-group"
  }
}

# Output Security Group ID
output "eks_node_security_group_id" {
  description = "Security Group ID for EKS worker nodes"
  value       = aws_security_group.eks_nodes.id
}

resource "aws_security_group" "codebuild_sg" {
  name        = "codebuild-sg"
  description = "Allow CodeBuild to communicate with EKS"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow outbound requests to EKS API"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [aws_security_group.eks_nodes.id]  # ✅ Allow access to EKS security group
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "codebuild-sg"
  }
}

output "codebuild_security_group_id" {
  description = "Security Group ID for CodeBuild"
  value       = aws_security_group.codebuild_sg.id
}
