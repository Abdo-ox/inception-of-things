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

require kubectl '
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/kubectl
'


