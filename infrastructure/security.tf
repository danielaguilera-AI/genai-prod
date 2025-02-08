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
