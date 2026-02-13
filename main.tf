provider "aws" {
  region = "us-east-1"
}

# 1. The Network (VPC)
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "alnafi-vpc"
  cidr = "10.0.0.0/16"

  azs              = ["us-east-1a", "us-east-1b"]
  private_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets   = ["10.0.101.0/24", "10.0.102.0/24"]
  
  # Dedicated subnets for RDS & Redis
  database_subnets = ["10.0.21.0/24", "10.0.22.0/24"]
  create_database_subnet_group = true

  enable_nat_gateway = true
  single_nat_gateway = true # Cost optimization
}

# 2. The Kubernetes Cluster (EKS)
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "alnafi-production-cluster"
  cluster_version = "1.29"

  cluster_endpoint_public_access = true
  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    spot_nodes = {
      instance_types = ["t3.medium", "t3.large"]
      capacity_type  = "SPOT" # 90% discount
      min_size     = 2
      max_size     = 4
      desired_size = 2
    }
  }
}

# 3. Security Group for Databases
resource "aws_security_group" "db_sg" {
  name   = "openedx-db-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
  }
}

# 4. RDS MySQL (Managed & External)
resource "aws_db_instance" "mysql" {
  identifier           = "openedx-mysql"
  allocated_storage    = 20
  db_name              = "openedx"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro" # Free Tier
  username             = "dbadmin"
  password             = "AqibPass123!" # Change later!
  parameter_group_name = "default.mysql8.0"
  db_subnet_group_name = module.vpc.database_subnet_group_name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot  = true
}

# 5. ElastiCache Redis (Managed & External)
resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "openedx-redis"
  engine               = "redis"
  node_type            = "cache.t3.micro" # Free Tier
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  port                 = 6379
  subnet_group_name    = module.vpc.database_subnet_group_name
  security_group_ids   = [aws_security_group.db_sg.id]
}
