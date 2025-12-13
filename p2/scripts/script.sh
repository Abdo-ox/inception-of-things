
#!/bin/bash

set -e

echo "===> start the k3s server installation."
curl -sfL https://get.k3s.io | sh -
echo "===> K3s server installed."

echo "===> Waiting the token to be created..."
while true; do
  if [ -f "/var/lib/rancher/k3s/server/node-token" ];then
    echo "Token created successfully."
    break
  else
    sleep 1
    echo "Waiting..."
  fi
done

sudo kubectl apply -f /tmp/deployment.yaml
sudo kubectl apply -f /tmp/service.yaml
sudo kubectl apply -f /tmp/ingress.yaml

echo "===> Waiting the pods to be created."
until kubectl get pod --no-headers 2>/dev/null | grep -q .;do
    sleep 1
    echo "Waiting..."
done

echo "===> Waiting for the app to start..."
sudo kubectl wait --for=condition=ready pod --all --timeout=300s
echo "===> The app started successfully."

echo "===> Created alias for kubectl"
echo "alias k='kubectl'" >> /home/vagrant/.bashrc
echo "===> Alter the k3s.yml file permission for using kubectl command without sudo"
sudo chmod 777 /etc/rancher/k3s/k3s.yaml
echo "##App is ready##"
    