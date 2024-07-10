# Redis Cluster
resource "aws_elasticache_cluster" "redis_1" {
  cluster_id               = var.redis_cluster_id
  engine                   = var.redis_engine
  node_type                = var.redis_node_type
  num_cache_nodes          = var.redis_num_cache_nodes
  parameter_group_name     = aws_elasticache_parameter_group.elasticache_parameter_group_1.name
  engine_version           = var.redis_engine_version
  port                     = var.redis_port
  snapshot_retention_limit = var.redis_snapshot_retention_days
  subnet_group_name        = aws_elasticache_subnet_group.redis_subnet_group_1.name
  security_group_ids       = [aws_security_group.redis_security_group_1.id]

  depends_on = [aws_security_group.redis_security_group_1]
}

resource "aws_elasticache_parameter_group" "elasticache_parameter_group_1" {
  name   = "elasticache-parameter-group-1"
  family = var.redis_parameter_group_name

  parameter {
    name  = "cluster-enabled"
    value = "no"
  }
}
