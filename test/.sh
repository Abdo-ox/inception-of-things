#!/bin/bash

CLUSTER_NAME="MyCluster"

#Colors 
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

if ! k3d cluster list | grep -q "^${CLUSTER_NAME}"; then
  echo -e "${BLUE}====> creating the cluster ...\n${NC}"
  k3d cluster create mycluster -p "80:80@loadbalancer" -p "443:443@loadbalancer"
  echo -e "${GREEN}====> cluster ${CLUSTER_NAME} created.\n${NC}"
else
  echo -e "${GREEN}====> already created.\n${NC}"
fi

kubectl create namespace argocd
kubectl create namespace dev

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl wait --for=condition=ready pod -n argocd --all --timeout=300s
kubectl -n argocd patch deployment argocd-server \
  --type='json' \
  -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--insecure"}]'
kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d > secret 
echo "" >> secret
kubectl apply -f deploy.yaml
helm upgrade --install gitlab gitlab/gitlab \
  --namespace gitlab --create-namespace \
  --values https://gitlab.com/gitlab-org/charts/gitlab/raw/master/examples/values-minikube-minimum.yaml \
  --set global.hosts.domain="localhost" \
  --set global.hosts.externalIP=0.0.0.0 \
  --set global.hosts.https=false \
  --set certmanager.install=false \
  --set global.ingress.configureCertmanager=false \
  --timeout 600s \
  --wait
kubectl wait --for=condition=ready pod -n gitlab --all --timeout=300s
kubectl get secret -n gitlab gitlab-gitlab-initial-root-password -o jsonpath="{.data.password}" | base64 -d >> secret 