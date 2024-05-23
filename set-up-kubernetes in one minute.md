Here's a complete shell script that encapsulates the entire process of setting up a Kubernetes cluster using `kind` on an Ubuntu EC2 instance, from installing Docker to deploying a sample application. Save this script as `setup-kind-k8s.sh` and run it on your EC2 instance.

```sh
#!/bin/bash

# Step 1: Update and install necessary packages
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Step 2: Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce

# Verify Docker installation
sudo systemctl status docker

# Add the user to the Docker group (optional)
sudo usermod -aG docker ${USER}
newgrp docker

# Step 3: Install Kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.14.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Verify Kind installation
kind version

# Step 4: Create Kind Cluster
cat <<EOF >kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
EOF

# Create the cluster using the configuration file
kind create cluster --config kind-config.yaml

# Step 5: Install Kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Verify Kubectl installation
kubectl version --client

# Step 6: Verify Cluster Nodes
kubectl get nodes

# Step 7: Deploy a Sample Application
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=NodePort

# Step 8: Get the NodePort and Public IP
NODE_PORT=$(kubectl get svc nginx -o go-template='{{(index .spec.ports 0).nodePort}}')
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

# Step 9: Access the Application
echo "You can access the Nginx application at http://$PUBLIC_IP:$NODE_PORT"

# End of script
```

### Usage Instructions

1. **Launch an Ubuntu EC2 Instance**:
   - Select an Ubuntu Server 20.04 LTS AMI.
   - Choose an instance type (t2.medium or larger).
   - Configure security group rules to allow SSH (port 22), HTTP (port 80), and HTTPS (port 443).

2. **Connect to Your EC2 Instance**:
   - SSH into your instance using the key pair you selected during instance creation:
     ```sh
     ssh -i /path/to/your-key-pair.pem ubuntu@your-ec2-public-ip
     ```

3. **Upload and Run the Script**:
   - Copy the script (`setup-kind-k8s.sh`) to your EC2 instance.
   - Make the script executable and run it:
     ```sh
     chmod +x setup-kind-k8s.sh
     ./setup-kind-k8s.sh
     ```

4. **Access the Deployed Application**:
   - After the script completes, it will output the public IP address and port where the Nginx application is accessible. Open your browser and navigate to:
     ```
     http://<your-ec2-public-ip>:<node-port>
     ```

This script automates the entire process of setting up a Kubernetes cluster using `kind` and deploying a sample Nginx application. It includes steps for installing Docker, `kind`, and `kubectl`, as well as creating a cluster and verifying the deployment.