resource "aws_efs_file_system" "jira" {
  encrypted = true

  tags = {
    Name = "${var.project_name}-jira-efs"
  }
}

resource "aws_efs_mount_target" "jira" {
  count          = length(module.network.private_subnet_ids)
  file_system_id = aws_efs_file_system.jira.id
  subnet_id      = module.network.private_subnet_ids[count.index]

  security_groups = [aws_security_group.jira_efs.id]
}

resource "aws_security_group" "jira_efs" {
  name   = "${var.project_name}-jira-efs-sg"
  vpc_id = module.network.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
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

output "jira_efs_id" {
  value = aws_efs_file_system.jira.id
}
