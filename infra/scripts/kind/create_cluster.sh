# https://kind.sigs.k8s.io

# doc: https://www.danielstechblog.io/local-kubernetes-setup-with-kind/


[ ! -f /usr/local/bin/kind ]  &&  ./scripts/kind/kind_install.sh  &&  echo "Kind installed."

kind create cluster --name $1 --config=./scripts/kind/config-cluster.yaml

echo
echo "Deploying NGINX Ingress Controller..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml --wait=true

