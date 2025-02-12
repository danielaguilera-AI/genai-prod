# ============================================================
# ECS CLUSTER (FARGATE)
# ============================================================

resource "aws_ecs_cluster" "llm_cluster" {
  name = "llm-cluster"
}

resource "aws_ecs_cluster_capacity_providers" "llm_cluster_capacity" {
  cluster_name = aws_ecs_cluster.llm_cluster.name
  capacity_providers = ["FARGATE"]
}
