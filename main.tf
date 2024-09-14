terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.67.0"
    }
  }
}

terraform {
  backend "s3" {
    bucket = "mybucket"
    key    = "path/to/my/key"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.region
}
#Creating the VPC using module
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = var.vpc_name
  cidr = var.cidr
  azs             = var.avilability_zone
  public_subnets  = var.public_subnets
  tags = {
    Terraform = "true"
    Environment = "UAT" 
  }
}

#Cloudwatch using modules
module "log_metric_filter" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/log-metric-filter"
  version = "~> 3.0"

  log_group_name = var.log_group_name
  log_group_retention_in_days = var.retention_in_days
  log_stream_name = var.stream_name
  alarm_name = var.alarm_name
  alarm_comparison_operator = var.alarm_comparison_operator
  alarm_evaluation_periods  = var.alarm_evaluation_periods
  alarm_threshold           = var.alarm_threshold
  alarm_period              = var.alarm_period
  alarm_namespace   = var.alarm_namespace
  alarm_metric_name = var.alarm_metric_name
  alarm_statistic   = var.alarm_statistic
  instance_id = var.instance_id
  sns_topic_name = var.sns_topic_name
  
}

resource "aws_instance" "jenkins_server" {
  ami           = "${data.aws_ami.linux.id}"
  instance_type = "t2.micro"

  tags = {
    Name = "Jakins_server"
  }
}

data "aws_ami" "linux" {
  most_recent = true
  owners = [ "amazon" ]
  filter {
    name   = "name"
    values = ["al2023-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "Architecture-type"
    values = ["x86_64"]
  }
}


module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "s3-bucket_CD1"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }
}
