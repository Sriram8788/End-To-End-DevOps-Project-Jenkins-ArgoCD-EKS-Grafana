variable "region" {
  type = string
}
variable "vpc_name" {
    type = string
}

variable "cidr" {
  type = string
}

variable "avilability_zone" {
    type = list(string) 
}
variable "public_subnets" {
  type = list(string)
}
variable "ani_name" {
  type = string
}
variable "log_group_name" {
  type = string
}

variable "retention_in_days" {
  type = string
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
  type = string
}
variable "alarm_threshold" {
  type = string
}
variable "alarm_period" {
  type = string
}
variable "alarm_namespace" {
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
variable "instance_id" {
  type = string
}
