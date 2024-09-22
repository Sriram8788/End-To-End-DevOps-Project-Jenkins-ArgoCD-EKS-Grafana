# main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.67.0"
    }
  }

  backend "s3" {
    bucket = "hare-ram-s3-bucket"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.region
}

# Create public subnets using the VPC module
module "my_vpc" {
  source                  = "terraform-aws-modules/vpc/aws"
  version                 = "5.13.0"
  name                    = var.vpc_name
  cidr                    = var.cidr
  azs                     = var.availability_zones
  public_subnets          = var.public_subnets
  map_public_ip_on_launch = true

  tags = {
    Terraform   = "true"
    Environment = "UAT"
  }
}

# Create a local value for subnet IDs
locals {
  subnet_ids = module.my_vpc.public_subnets
}

# Use null_resource to execute AWS CLI command to modify public subnets
resource "null_resource" "modify_public_subnets" {
  count = length(local.subnet_ids)

  provisioner "local-exec" {
    command = "aws ec2 modify-subnet-attribute --subnet-id ${local.subnet_ids[count.index]} --map-public-ip-on-launch"
  }

  depends_on = [module.my_vpc]
}

# EC2 Jenkins instance
resource "aws_instance" "jenkins_server" {
  ami                         = data.aws_ami.linux.id
  instance_type               = var.instance_type
  subnet_id                   = module.my_vpc.public_subnets[0]
  associate_public_ip_address = true
  security_groups             = [aws_security_group.ec2_sg.id]
  key_name                    = var.key_name
  tags = {
    Name = "Jenkins_server"
  }
  user_data              = file("./ansible.sh")
}

resource "null_resource" "install_ansible" {
  # The provisioner will run this command after the Jenkins instance is created
  provisioner "local-exec" {
    command = "bash ${path.module}/ansible.sh"
  }

  depends_on = [aws_instance.jenkins_server]
}

data "aws_ami" "linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Security group for EC2
resource "aws_security_group" "ec2_sg" {
  name        = "ec2_sg"
  description = "Allow inbound traffic for EC2"
  vpc_id      = module.my_vpc.vpc_id

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_security_group_rule" "ingress_tls" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [var.cidr]
  security_group_id = aws_security_group.ec2_sg.id
}

resource "aws_security_group_rule" "ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [var.cidr]
  security_group_id = aws_security_group.ec2_sg.id
}

resource "aws_security_group_rule" "ingress_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.cidr]
  security_group_id = aws_security_group.ec2_sg.id
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2_sg.id
}

# Attach volumes to EC2
resource "aws_ebs_volume" "jenkins_volume" {
  availability_zone = aws_instance.jenkins_server.availability_zone
  size              = 40

  tags = {
    Name = "Jenkins_volume"
  }
}

resource "aws_volume_attachment" "jenkins_attachment" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.jenkins_volume.id
  instance_id = aws_instance.jenkins_server.id
}

/*
# Route Table for public subnets
resource "aws_route_table" "public_rt" {
  vpc_id = module.my_vpc.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = module.my_vpc.igw_id
  }

  tags = {
    Name = "${var.vpc_name}-public-route-table"
  }
}

resource "aws_route_table_association" "public_subnet_association_1" {
  subnet_id      = module.my_vpc.public_subnets[0]
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_subnet_association_2" {
  subnet_id      = module.my_vpc.public_subnets[1]
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_subnet_association_3" {
  subnet_id      = module.my_vpc.public_subnets[2]
  route_table_id = aws_route_table.public_rt.id
}
*/

# EKS Cluster IAM Roles and Policies
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks_cluster_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role" "eks_node_role" {
  name = "eks_node_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_node_worker_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_node_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_node_registry_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = module.my_vpc.public_subnets
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = module.my_vpc.public_subnets

  scaling_config {
    desired_size = var.desired_capacity
    max_size     = var.max_size
    min_size     = var.min_size
  }

  instance_types = [var.instance_type]

  remote_access {
    ec2_ssh_key = var.ssh_key_name
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_worker_policy,
    aws_iam_role_policy_attachment.eks_node_cni_policy,
    aws_iam_role_policy_attachment.eks_node_registry_policy
  ]
}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = var.log_group_name
  retention_in_days = var.retention_in_days
}

resource "aws_cloudwatch_log_stream" "log_stream" {
  name           = var.stream_name
  log_group_name = aws_cloudwatch_log_group.log_group.name
}


# CloudWatch Log Metric Filter
resource "aws_cloudwatch_log_metric_filter" "log_metric_filter" {
  name           = var.alarm_name
  log_group_name = var.log_group_name
  pattern        = var.filter_pattern

  metric_transformation {
    name      = var.alarm_metric_name
    namespace = var.alarm_namespace # Change this to your own namespace, e.g., "Custom/EKS"
    value     = "1"
  }
}

# CloudWatch Alarm
resource "aws_cloudwatch_metric_alarm" "log_metric_alarm" {
  alarm_name          = var.alarm_name
  comparison_operator = var.alarm_comparison_operator
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = var.alarm_metric_name
  namespace           = var.alarm_namespace
  period              = var.alarm_period
  statistic           = var.alarm_statistic
  threshold           = var.alarm_threshold
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.sns_topic.arn]
}

# SNS Topic
resource "aws_sns_topic" "sns_topic" {
  name = var.sns_topic_name
}

resource "aws_sns_topic_subscription" "sns_subscription" {
  topic_arn = aws_sns_topic.sns_topic.arn
  protocol  = "email"
  endpoint  = var.sns_email
}

