# Kubernetes Deployment on Ubuntu 24.04

This guide explains how to set up a Kubernetes cluster (using K3s) and deploy the application on a fresh Ubuntu 24 VPS.

## 🚀 1. Setup Environment
Copy the `setup.sh` script to your server and run it. This installs Docker and K3s.

```bash
cd aws-spring-react-crud/k8s
chmod +x setup.sh
./setup.sh
```

**Important**: Log out and log back in to refresh permissions.

## 📦 2. Build Images
Since we are using a local cluster (K3s), we need to import images directly.

**Option A: Build directly in K3s containerd**
```bash
# Build images using docker (which we just installed)
cd ..
docker build -t spring-boot-backend:latest ./backend
docker build -t react-frontend:latest ./frontend

# Save to K3s
docker save spring-boot-backend:latest | sudo k3s ctr images import -
docker save react-frontend:latest | sudo k3s ctr images import -
```

## ☸️ 3. Deploy
Apply the configuration:
```bash
kubectl apply -f deployment.yaml
```

## 🌐 4. Access
The app uses a `NodePort` service exposed on port `30080`.

Open in browser:
`http://<your-server-ip>:30080`
