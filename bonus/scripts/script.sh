GREEN='\e[0;32m'
BLUE='\e[0;34m'
YELLOW='\e[1;33m'
ORANGE='\e[38;5;214m'
NC='\e[0m'
CLUSTER_NAME="MyCluster"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

message(){
  echo "${1}===> ${2}\n${NC}"
}

set -e

message "$ORANGE" "creating the k3d cluster ander ${CLUSTER_NAME}..."
if ! k3d cluster list | grep -q $CLUSTER_NAME; then 
  k3d cluster create $CLUSTER_NAME -p "80:80@loadbalancer" -p "443:443@loadbalancer" -p "8000:30000@loadbalancer" -p "8888:30001@loadbalancer" -p "8001:30002@loadbalancer"
  message "$GREEN" "k3d cluster created successfully."
else
  message $BLUE "cluter with the name ${CLUSTER_NAME} already created."
fi

message "$ORANGE" "creating namespaces argocd and dev..."
if ! kubectl get ns | grep -q "argocd"; then
  kubectl create namespace argocd
else
  message $BLUE "argocd namespace already exist."
fi

if ! kubectl get ns | grep -q "dev"; then
  kubectl create namespace dev
else
  message $BLUE "dev namespace already exist."
fi

message "$ORANGE" "installing argocd ..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
message "$BLUE" "argocd installed successfully."

message "$ORANGE" "waiting the argocd pod get ready..."
kubectl wait --for=condition=ready pod -n argocd --all --timeout=300s
message "$ORANGE" "Argocd pod are ready..."

kubectl patch svc argocd-server -p '{"spec": {"type": "NodePort", "ports":[{"port":80,"targetPort":8080,"nodePort":30000}]}}' -n argocd
message "$BLUE" "patch the argocd to nodePort to be accessible from the outside and give the port mapped."


kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d > $SCRIPT_DIR/secrets 

message "$GREEN" "link argocd to the public repo."

message "$ORANGE" "instaling gitlab..."
helm repo add gitlab https://charts.gitlab.io/
helm repo update
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
message "$GREEN" "store the password for the root user in the secrets file."
echo "" >> $SCRIPT_DIR/secrets
kubectl get secret -n gitlab gitlab-gitlab-initial-root-password -o jsonpath="{.data.password}" | base64 -d >> $SCRIPT_DIR/secrets
kubectl patch svc gitlab-webservice-default -p '{"spec": {"type": "NodePort", "ports":[{"name": "webserver", "port":80,"targetPort":8181,"nodePort":30002}]}}' -n gitlab
