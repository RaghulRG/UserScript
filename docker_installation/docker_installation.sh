#!/bin/bash

set -e

# Function to print message in green
function info() {
  echo -e "\e[32m[INFO]\e[0m $1"
}

# Detect OS and VERSION
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VERSION=$VERSION_ID
else
    echo "[ERROR] Cannot detect OS type."
    exit 1
fi

info "Detected OS: $OS, Version: $VERSION"

install_docker_ubuntu_debian() {
    info "Installing Docker on Ubuntu/Debian..."
    sudo apt-get update
    sudo apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/$OS/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$OS \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

install_docker_centos_rhel_fedora() {
    info "Installing Docker on CentOS/RHEL/Fedora/Rocky/AlmaLinux..."

    sudo dnf -y remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine || true
    sudo dnf -y install dnf-plugins-core

    sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

    sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    sudo systemctl enable --now docker
}

case "$OS" in
    ubuntu|debian)
        install_docker_ubuntu_debian
        ;;
    centos|rhel|rocky|almalinux|fedora)
        install_docker_centos_rhel_fedora
        ;;
    *)
        echo "[ERROR] Unsupported OS: $OS"
        exit 1
        ;;
esac

# Add current user to docker group
if ! groups $USER | grep -q '\bdocker\b'; then
    sudo usermod -aG docker $USER
    info "Added $USER to docker group. Please log out and back in for changes to take effect."
fi

info "Docker installation complete!"
docker --version

