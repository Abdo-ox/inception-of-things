echo "===> start the k3s server installation."
curl -sfL https://get.k3s.io | sh -
echo "===> K3s server installed."

echo "===> Waiting the token to be created..."
while true; do
  if [ -f "/var/lib/rancher/k3s/server/node-token" ];then
    echo "Token created successfully."
    sudo cat /var/lib/rancher/k3s/server/node-token > /vagrant/token
    break
  else
    sleep 1
    echo "Waiting..."
  fi
done
echo "===> Created alias for kubectl"
echo "alias k='kubectl'" >> /home/vagrant/.bashrc
chown vagrant:vagrant /home/vagrant/.bashrc
echo "===> Alter the k3s.yml file permission for using kubectl command without sudo"
sudo chmod 777 /etc/rancher/k3s/k3s.yaml
echo "##Server is ready##"