variable "region" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "cidr" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}

variable "ami_name" {
  type = string
}

variable "log_group_name" {
  type = string
}

variable "retention_in_days" {
  type = number
}
variable "stream_name" {
  type = string
}
variable "alarm_name" {
  type = string
}
variable "alarm_comparison_operator" {
  type = string
}
variable "alarm_evaluation_periods" {
  type = number
}
variable "alarm_threshold" {
  type = number
}
variable "alarm_period" {
  type = number
}
variable "alarm_namespace" {
  type = string
}
variable "filter_pattern" {
  type = string
}
variable "alarm_metric_name" {
  type = string
}
variable "alarm_statistic" {
  type = string
}
variable "sns_topic_name" {
  type = string
}
variable "sns_email" {
  type = string
}

variable "instance_id" {
  type = string
}

variable "key_name" {
  type = string
}
/*
variable "access_key" {
  type      = string
}

variable "secret_key" {
  type      = string
  
}
*/

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "desired_capacity" {
  description = "Desired number of worker nodes"
  type        = number
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
}

variable "instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
}

variable "ssh_key_name" {
  description = "SSH key name to use for EC2 instances"
  type        = string
}

