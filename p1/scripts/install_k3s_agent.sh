#!/bin/bash

SERVER_IP="192.168.56.110"

# Get the token from the K3s server
TOKEN=$(curl -s http://$SERVER_IP:8080/v1-k3s/server-token)

# Install K3s agent and join server
curl -sfL https://get.k3s.io | K3S_URL="https://$SERVER_IP:6443" K3S_TOKEN="$TOKEN" sh -

echo "K3s agent installed and joined the cluster successfully."
