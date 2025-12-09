#!/bin/bash

# Install K3s server
curl -sfL https://get.k3s.io | sh -

# Copy kubeconfig for vagrant user
cp /etc/rancher/k3s/k3s.yaml /home/vagrant/config
chown vagrant:vagrant /home/vagrant/config

echo "K3s server installed successfully."
