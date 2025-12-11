
#!/bin/bash
echo "===> get the token from the shared directory."
SERVER_TOKEN=$(cat /vagrant/token)

echo "===> install the k3s agent & link with the k3s server"
curl -sfL https://get.k3s.io | K3S_URL="https://192.168.56.110:6443" K3S_TOKEN="$SERVER_TOKEN" sh -

echo "##Agent is ready##"