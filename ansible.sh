#!/bin/bash
sudo yum install ansible -y
sudo yum install python3-pip -y
pip3 install boto3 botocore
sudo yum install git -y
git clone https://github.com/Sriram8788/End-To-End-DevOps-Project-Jenkins-ArgoCD-EKS-Grafana.git

mv End-To-End-DevOps-Project-Jenkins-ArgoCD-EKS-Grafana Devops_project