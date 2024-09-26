#terraform.tf
region                    = "us-east-1"
vpc_name                  = "aws_vpc"
cidr                      = "10.0.0.0/16"
availability_zones        = ["us-east-1a", "us-east-1b", "us-east-1c"]
public_subnets            = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
ami_name                  = "al2023-ami-2023.5.20240916.0-kernel-6.1-x86_64"
log_group_name            = "Jenkins-logs"
retention_in_days         = 5
stream_name               = "Jenkins-stream"
alarm_name                = "Jenkins-alarm"
alarm_comparison_operator = "GreaterThanOrEqualToThreshold"
alarm_evaluation_periods  = 1
alarm_threshold           = 50
alarm_period              = 60
alarm_namespace           = "Custom/EC2"
alarm_metric_name         = "CPUUtilization"
alarm_statistic           = "Average"
instance_id               = ""
sns_topic_name            = "Jenkins-sns-topic"
sns_email                 = "awsherorajkumar@gmail.com"
key_name                  = "sonar"
desired_capacity          = 2
max_size                  = 2
min_size                  = 2
cluster_name              = "Eks_Cluster_main"
instance_type             = "t3.medium"
ssh_key_name              = "sonar"
filter_pattern            = "{ $.errorCount = * }" # Example value; adjust as needed

