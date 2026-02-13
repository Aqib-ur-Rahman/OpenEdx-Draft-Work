https://gemini.google.com/share/8cd5cc9797b3

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




Yes, you can absolutely use ChatGPT for free. OpenAI offers a standard Free Tier, but there are also a few ways to access premium features without paying the full $20/month subscription.
+1

Here is the breakdown of how to get ChatGPT for free in 2026:

1. The Official ChatGPT Free Tier
The simplest way is to create an account at chatgpt.com.

Model Access: You get access to the latest models (like GPT-5.2), though with usage limits. Once you hit your limit, the system automatically switches you to a more basic "mini" model.

Capabilities: You can search the web, analyze data, and upload files or images.

New in 2026: OpenAI has introduced ads to the free tier in several regions to help keep the service accessible without a subscription.

2. The "ChatGPT Go" 12-Month Trial (Regional)
OpenAI recently launched ChatGPT Go, a budget-friendly tier ($8/month). There is a confirmed promotion offering 12 months for free, but it is currently focused on specific markets:
+1

India: There is a widely reported 1-year free trial for users in India using local payment methods (UPI/Card).

Global: If you aren't in a trial region, look for the "Try Go" banner in your app settings; OpenAI occasionally rolls out 7-day or 1-month trials to active free users to test the tier.

3. Alternative Official Channels
If you want "Plus-like" features (like reasoning or higher image generation limits) for free, you can use these platforms that use OpenAI's models as a backbone:

Microsoft Copilot: This is the most robust free alternative. It provides access to high-end GPT models and DALL-E image generation for free through the web or the Copilot app.

Perplexity AI: Great for research, it often allows a limited number of "Pro" searches per day using advanced models.

Developer Free Credits: If you are a developer, signing up for an OpenAI API account sometimes grants $5–$18 in free credits to new users, which you can use to "pay as you go" instead of a flat monthly fee.

4. Shared Invitations
If you know someone with a ChatGPT Plus subscription, they can generate invite codes.

These codes typically give you 7 to 14 days of full Plus access.

You will usually need to link a card to activate it, so remember to cancel before the trial ends if you don't want to be charged.


Since you're working as a Junior DevOps Engineer, are you looking for a way to use ChatGPT for specific coding or automation tasks, or just general use?Yes, you can absolutely use ChatGPT for free. OpenAI offers a standard Free Tier, but there are also a few ways to access premium features without paying the full $20/month subscription.
+1

Here is the breakdown of how to get ChatGPT for free in 2026:

1. The Official ChatGPT Free Tier
The simplest way is to create an account at chatgpt.com.

Model Access: You get access to the latest models (like GPT-5.2), though with usage limits. Once you hit your limit, the system automatically switches you to a more basic "mini" model.

Capabilities: You can search the web, analyze data, and upload files or images.

New in 2026: OpenAI has introduced ads to the free tier in several regions to help keep the service accessible without a subscription.

2. The "ChatGPT Go" 12-Month Trial (Regional)
OpenAI recently launched ChatGPT Go, a budget-friendly tier ($8/month). There is a confirmed promotion offering 12 months for free, but it is currently focused on specific markets:
+1

India: There is a widely reported 1-year free trial for users in India using local payment methods (UPI/Card).

Global: If you aren't in a trial region, look for the "Try Go" banner in your app settings; OpenAI occasionally rolls out 7-day or 1-month trials to active free users to test the tier.

3. Alternative Official Channels
If you want "Plus-like" features (like reasoning or higher image generation limits) for free, you can use these platforms that use OpenAI's models as a backbone:

Microsoft Copilot: This is the most robust free alternative. It provides access to high-end GPT models and DALL-E image generation for free through the web or the Copilot app.

Perplexity AI: Great for research, it often allows a limited number of "Pro" searches per day using advanced models.

Developer Free Credits: If you are a developer, signing up for an OpenAI API account sometimes grants $5–$18 in free credits to new users, which you can use to "pay as you go" instead of a flat monthly fee.

4. Shared Invitations
If you know someone with a ChatGPT Plus subscription, they can generate invite codes.

These codes typically give you 7 to 14 days of full Plus access.

You will usually need to link a card to activate it, so remember to cancel before the trial ends if you don't want to be charged.


Since you're working as a Junior DevOps Engineer, are you looking for a way to use ChatGPT for specific coding or automation tasks, or just general use?


