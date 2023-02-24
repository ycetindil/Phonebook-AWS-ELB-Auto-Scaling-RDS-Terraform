terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.10.0"
    }
    github = {
      source  = "integrations/github"
      version = "4.23.0"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "github" {
  token = file("${var.github_token_path}/${var.github_token_filename}")
}

##########
# GitHub #
##########
resource "github_repository_file" "dbendpoint" {
  content             = aws_db_instance.db_server.address
  file                = "dbserver.endpoint"
  repository          = var.github_repo_name
  branch              = var.github_repo_branch
  overwrite_on_create = true
  depends_on = [
    aws_db_instance.db_server
  ]
}

################
# VPC & Subnet #
################
data "aws_vpc" "default_vpc" {
  default = true
}

data "aws_subnets" "subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_vpc.id]
  }
}

#############
# DB Server #
#############
resource "aws_security_group" "db_sg" {
  name   = "DBSecurityGroup"
  vpc_id = data.aws_vpc.default_vpc.id
  tags = {
    "Name" = "DBSecurityGroup"
  }

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.lt_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "db_server" {
  instance_class              = "db.t2.micro"
  allocated_storage           = 20 # GB
  vpc_security_group_ids      = [aws_security_group.db_sg.id]
  allow_major_version_upgrade = false
  auto_minor_version_upgrade  = true
  backup_retention_period     = 0
  identifier                  = "${var.prefix}-db"
  db_name                     = var.db_server_name
  engine                      = "mysql"
  engine_version              = "8.0.28"
  username                    = var.db_username
  password                    = var.db_password
  monitoring_interval         = 0
  multi_az                    = false
  port                        = 3306
  publicly_accessible         = false
  skip_final_snapshot         = true
}

###################
# Launch Template #
###################
data "aws_ami" "amazon_linux_2" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10*"]
  }
}

resource "aws_security_group" "lt_sg" {
  name   = "LTSecurityGroup"
  vpc_id = data.aws_vpc.default_vpc.id
  tags = {
    Name = "LTSecurityGroup"
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_template" "lt" {
  name                   = "${var.prefix}-lt"
  image_id               = data.aws_ami.amazon_linux_2.id
  instance_type          = "t2.micro"
  key_name               = var.ssh_key_name
  vpc_security_group_ids = [aws_security_group.lt_sg.id]
  user_data              = filebase64("user-data.sh")
  depends_on             = [github_repository_file.dbendpoint]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = var.prefix
    }
  }
}

#############################
# Application Load Balancer #
#############################
resource "aws_alb_target_group" "alb_tg" {
  name        = "${var.prefix}-alb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default_vpc.id
  target_type = "instance"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

resource "aws_security_group" "alb_sg" {
  name   = "ALBSecurityGroup"
  vpc_id = data.aws_vpc.default_vpc.id
  tags = {
    Name = "ALBSecurityGroup"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = aws_alb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.alb_tg.arn
  }
}

resource "aws_alb" "alb" {
  name               = "${var.prefix}-alb"
  ip_address_type    = "ipv4"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = data.aws_subnets.subnets.ids
}

######################
# Auto Scaling Group #
######################
resource "aws_autoscaling_group" "asg" {
  max_size                  = 3
  min_size                  = 1
  desired_capacity          = 2
  name                      = "${var.prefix}-asg"
  health_check_grace_period = 300
  health_check_type         = "ELB"
  target_group_arns         = [aws_alb_target_group.alb_tg.arn]
  vpc_zone_identifier       = aws_alb.alb.subnets

  launch_template {
    id      = aws_launch_template.lt.id
    version = aws_launch_template.lt.latest_version
  }
}