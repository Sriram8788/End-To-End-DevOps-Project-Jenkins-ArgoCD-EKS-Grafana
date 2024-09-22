#output.tf
output "ec2_id" {
  value = aws_instance.jenkins_server.id
}

output "eks_cluster_id" {
  description = "The EKS cluster ID"
  value       = aws_eks_cluster.eks_cluster.id
}

output "eks_cluster_endpoint" {
  description = "The endpoint for the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.endpoint
}

output "eks_cluster_arn" {
  description = "The ARN of the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.arn
}

output "eks_cluster_security_group_id" {
  description = "The security group ID of the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}

output "eks_node_group_id" {
  description = "The ID of the EKS node group"
  value       = aws_eks_node_group.eks_node_group.id
}

output "alarm_name" {
  value = aws_cloudwatch_metric_alarm.log_metric_alarm.alarm_name
}

output "sns_topic_arn" {
  value = aws_sns_topic.sns_topic.arn
}

# Output for CloudWatch log group name
output "log_group_name" {
  description = "The name of the CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.log_group.name
}

# Output for CloudWatch log stream name
output "log_stream_name" {
  description = "The name of the CloudWatch Log Stream"
  value       = aws_cloudwatch_log_stream.log_stream.name
}

# Output for VPC ID
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.my_vpc.vpc_id
}