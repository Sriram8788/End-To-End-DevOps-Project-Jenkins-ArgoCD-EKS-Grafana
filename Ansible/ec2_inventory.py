#!/usr/bin/env python3

import boto3
import json
import sys

def main():
    # Specify your AWS region
    region = 'us-east-1'  # Change this to your desired region

    try:
        # Create an EC2 client
        ec2 = boto3.client('ec2', region_name=region)

        # Describe instances
        instances = ec2.describe_instances()

        # Prepare the inventory
        hosts = {}

        for reservation in instances['Reservations']:
            for instance in reservation['Instances']:
                if instance['State']['Name'] == 'running':
                    host_id = instance['InstanceId']
                    hosts[host_id] = {
                        'ansible_host': instance['PrivateIpAddress'],  # IP for Ansible connection
                        'ansible_ssh_user': 'ec2-user',               # SSH user
                        'ansible_ssh_private_key_file': '/home/ec2-user/Devops_project/sonar.pem'  # Path to your .pem file
                    }

        print(json.dumps(hosts))

    except Exception as e:
        print(f"Error fetching EC2 instances: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
