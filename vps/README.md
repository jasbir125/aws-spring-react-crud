# VPS Deployment Guide (Hostinger/DigitalOcean/Linode)

This guide explains how to deploy the application to any Virtual Private Server (VPS) running Linux (e.g., Ubuntu).

## 📋 Prerequisites
1.  **A VPS**: Purchased from a provider (Hostinger, DigitalOcean, etc.).
2.  **SSH Access**: You can log in to your server.
3.  **Domain Name (Optional)**: If you want a custom URL.

## 🚀 Deployment Steps

### 1. SSH into your VPS
Open your terminal and log in:
```bash
ssh root@<your-vps-ip>
```

### 2. Install Docker & Git
Run these commands on your VPS to install the necessary tools:
```bash
# Update packages
sudo apt-get update
sudo apt-get install -y git docker.io docker-compose

# Enable Docker
sudo systemctl enable docker
sudo systemctl start docker
```

### 3. Clone the Repository
Download your code to the server:
```bash
git clone <your-git-repo-url> aws-spring-react-crud
cd aws-spring-react-crud/vps
```
*Note: If your repo is private, you may need to use an SSH key or Personal Access Token.*

### 4. Start the Application
Run Docker Compose to build and start the app in the background:
```bash
sudo docker-compose up -d --build
```
*Note: On newer Docker versions, the command might be `docker compose up -d --build` (without the hyphen).*

### 5. Verify
Open your browser and visit:
`http://<your-vps-ip>`

You should see the React frontend running!

## 🔄 Updating the App
To deploy new changes:
1.  Pull the latest code:
    ```bash
    git pull
    ```
2.  Rebuild and restart:
    ```bash
    cd vps
    docker-compose up -d --build
    ```

## 🛠️ Troubleshooting
-   **Logs**: Check backend logs with `docker logs -f spring-boot-backend`.
-   **Ports**: Ensure your VPS firewall allows inbound traffic on port 80.
