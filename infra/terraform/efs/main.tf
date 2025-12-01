locals {
  allowed_cidr_blocks = length(var.allowed_cidr_blocks) > 0 ? var.allowed_cidr_blocks : [var.vpc_cidr]
}

resource "aws_efs_file_system" "jira" {
  encrypted = true

  tags = {
    Name = "${var.project_name}-jira-efs"
  }
}

resource "aws_security_group" "jira_efs" {
  name        = "${var.project_name}-jira-efs-sg"
  description = "Jira EFS security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = local.allowed_cidr_blocks
    description = "NFS from VPC or allowed CIDRs"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_efs_mount_target" "jira" {
  count          = length(var.private_subnet_ids)
  file_system_id = aws_efs_file_system.jira.id
  subnet_id      = var.private_subnet_ids[count.index]

  security_groups = [aws_security_group.jira_efs.id]
}
