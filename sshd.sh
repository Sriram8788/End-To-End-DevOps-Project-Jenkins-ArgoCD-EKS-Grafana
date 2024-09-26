#!/bin/bash
sudo yum install ansible -y
sudo yum install python3-pip -y
pip3 install boto3 botocore
sudo yum install git -y
git clone https://github.com/Sriram8788/End-To-End-DevOps-Project-Jenkins-ArgoCD-EKS-Grafana.git

mv End-To-End-DevOps-Project-Jenkins-ArgoCD-EKS-Grafana Devops_project


# Define the sshd_config file path
SSHD_CONFIG="/etc/ssh/sshd_config"

# Function to modify the sshd_config file
modify_sshd_config() {
    # Ensure PasswordAuthentication is set to yes
    if grep -q "^PasswordAuthentication" "$SSHD_CONFIG"; then
        sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/' "$SSHD_CONFIG"
    else
        echo "PasswordAuthentication yes" >> "$SSHD_CONFIG"
    fi

    # Ensure PermitRootLogin is set to yes
    if grep -q "^PermitRootLogin" "$SSHD_CONFIG"; then
        sed -i 's/^PermitRootLogin.*/PermitRootLogin yes/' "$SSHD_CONFIG"
    else
        echo "PermitRootLogin yes" >> "$SSHD_CONFIG"
    fi
}

# Function to restart the SSH service
restart_sshd_service() {
    sudo systemctl restart sshd
    if [ $? -eq 0 ]; then
        echo "SSHD service restarted successfully."
    else
        echo "Failed to restart SSHD service."
        exit 1
    fi
}

# Execute the functions
modify_sshd_config
restart_sshd_service
