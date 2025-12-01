resource "aws_db_subnet_group" "jira" {
  name       = "${var.project_name}-jira-db-subnet-group"
  subnet_ids = module.network.private_subnet_ids

  tags = {
    Name = "${var.project_name}-jira-db-subnet-group"
  }
}

resource "aws_db_instance" "jira" {
  allocated_storage    = 100
  engine               = "postgres"
  engine_version       = "15.4"
  instance_class       = "db.m5.large"
  db_name              = var.jira_db_name
  username             = var.jira_db_username
  password             = var.jira_db_password
  storage_encrypted    = true
  multi_az             = true
  skip_final_snapshot  = false
  deletion_protection  = true
  db_subnet_group_name = aws_db_subnet_group.jira.name

  vpc_security_group_ids = [aws_security_group.jira_db.id]

  tags = {
    Name = "${var.project_name}-jira-db"
  }
}

resource "aws_security_group" "jira_db" {
  name        = "${var.project_name}-jira-db-sg"
  description = "Jira DB security group"
  vpc_id      = module.network.vpc_id

  # In real setup, restrict to EKS node SG
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "jira_db_endpoint" {
  value = aws_db_instance.jira.address
}
