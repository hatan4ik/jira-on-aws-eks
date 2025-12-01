locals {
  allowed_cidr_blocks = length(var.allowed_cidr_blocks) > 0 ? var.allowed_cidr_blocks : [var.vpc_cidr]
}

resource "aws_db_subnet_group" "jira" {
  name       = "${var.project_name}-jira-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project_name}-jira-db-subnet-group"
  }
}

resource "aws_security_group" "jira_db" {
  name        = "${var.project_name}-jira-db-sg"
  description = "Jira DB security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = local.allowed_cidr_blocks
    description = "Postgres from VPC or allowed CIDRs"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-jira-db-sg"
  }
}

resource "aws_db_instance" "jira" {
  allocated_storage       = var.allocated_storage
  engine                  = "postgres"
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  db_name                 = var.db_name
  username                = var.username
  password                = var.password
  storage_encrypted       = true
  multi_az                = true
  backup_retention_period = var.backup_retention_period
  skip_final_snapshot     = false
  deletion_protection     = true
  publicly_accessible     = false
  db_subnet_group_name    = aws_db_subnet_group.jira.name

  vpc_security_group_ids = [aws_security_group.jira_db.id]

  tags = {
    Name = "${var.project_name}-jira-db"
  }
}
