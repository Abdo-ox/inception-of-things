#!/bin/bash

#Colors 
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

set -e

require() {
    echo -e "${BLUE}====> installing $1 ...${NC}\n"
    if ! which $1 > /dev/null 2>&1 ; then
        eval "$2"
        echo -e "${GREEN}====> ${1} installed successfully ✅${NC}\n"
    else
        echo -e "${GREEN}====> $1 already installed.${NC}\n"
    fi
}
set -e

require kubesctl '
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/kubectl
if ! grep -q "alias k=kubectl" ~/.zshrc;then
    echo "alias k=kubectl" >> ~/.zshrc
fi
'

require docker '
    sudo apt update
    sudo apt install -y ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt remove -y docker-buildx docker-compose
    sudo apt --fix-broken install -y
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo usermod -aG docker $USER
    newgrp docker
'

require k3d 'curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash'