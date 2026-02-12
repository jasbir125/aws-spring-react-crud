#!/bin/bash
set -e

# ONE-CLICK SETUP FOR UBUNTU 24.04 (Noble Numbat)
# Installs: Docker & K3s (Lightweight Kubernetes)

echo "🚀 Starting Setup for Ubuntu 24..."

# 1. Install Docker
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    # Add current user to docker group
    sudo usermod -aG docker $USER
    echo "✅ Docker Installed."
else
    echo "✅ Docker already installed."
fi

# 2. Install K3s (Lightweight K8s)
# Why K3s? It's production-ready, uses <512MB RAM, and is perfect for single-node VPS.
if ! command -v kubectl &> /dev/null; then
    echo "Installing K3s (Kubernetes)..."
    curl -sfL https://get.k3s.io | sh -
    
    # Configure kubectl for non-root user
    mkdir -p ~/.kube
    sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
    sudo chown $USER:$USER ~/.kube/config
    echo "export KUBECONFIG=~/.kube/config" >> ~/.bashrc
    
    echo "✅ Kubernetes (K3s) Installed."
else
    echo "✅ Kubernetes already installed."
fi

echo "------------------------------------------------"
echo "🎉 Setup Complete!"
echo "Please logout and login again for Docker group changes to take effect."
echo "Check status:"
echo "  docker ps"
echo "  kubectl get nodes"
