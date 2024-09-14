terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.67.0"
    }
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

  log_group_name = "my-application-logs"
  log_group_retention_in_days = ""
  log_stream_name = ""
  alarm_name = "my-application-logs-errors"
  alarm_comparison_operator = "GreaterThanOrEqualToThreshold"
  alarm_evaluation_periods  = 1
  alarm_threshold           = 10
  alarm_period              = 60
  alarm_namespace   = "MyApplication"
  alarm_metric_name = "ErrorCount"
  alarm_statistic   = "Maximum"
  instance_id = ""
  sn
  

}