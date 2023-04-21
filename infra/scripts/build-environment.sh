#!/bin/bash

# Parameters:
# 1: <k8s platform> (k3d)
# 2: <cluster name> (string)
# 3: <observab.> true|false
# ---
#  Pre-reqs: kubectl, helm
#  Usage: ./build-environment.sh <platform> <cluster_name> <true|false>


set -eu

[ -z "$1" ] && echo "Error: Missing cluster platform: kind|k3d|talos (p1)" && exit
[ -z "$2" ] && echo "Error: Missing cluster name... (p2)" && exit

echo
echo "+-----------------------------------+"
echo "| Starting K8s stack builder...     |"
echo "+-----------------------------------+"
echo
echo "Verifying Docker tools..."
echo "-------------------------------------"

[ ! -f /usr/bin/docker ]  &&  ./scripts/docker_install.sh  &&  echo ">> Docker installed!"  ||  echo "> Docker stack ok."


# k3d installation
echo
echo "Verifying K3d installation"
echo "-------------------------------------"
[ ! -f /usr/local/bin/k3d ]  &&  ./scripts/k3d/k3d_install.sh  &&  echo ">> K3d installed!"  ||  echo "> K3d binary ok."


# Helm installation
echo
echo "Verifying Helm installation"
echo "-------------------------------------"
[ ! -f /usr/local/bin/helm ]  &&  ./scripts/helm_install.sh  &&  echo ">> Helm installed!"  ||  echo "> Helm binary ok."


echo
echo "Reseting container env."
echo "-------------------------------------"

./scripts/reset_docker_stack.sh


echo
echo "Deploying k8s environment..."
echo "-------------------------------------"

# Platform
./scripts/$1/create_cluster.sh $2 2


echo
echo "Installing Argo and GitOps tools"
echo "-------------------------------------"
[ ! -f /usr/local/bin/argocd ]  &&  ./scripts/argocd-cli_install.sh  &&  \
  echo ">> ArgoCD CLI installed!"  ||  echo "> ArgoCD CLI is ok."

echo
echo "Auto-bootstraping cluster apps..."
echo "-------------------------------------"

[ ! -f /usr/local/bin/argocd-autopilot ]  &&  ./scripts/argocd_autopilot_install.sh  &&  \
  echo ">> ArgoCD AutoPilot installed!"  ||  echo "> ArgoCD AutoPilot is already OK"
./scripts/autopilot-bootstrap.sh  &&  echo "Autopilot bootstrap finished."

kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd  > /dev/null 2>&1

# Patching ArgoCD service type and node ports (v. port mappings for kind)
kubectl patch svc argocd-server -n argocd --patch \
  '{"spec": { "type": "NodePort", "ports": [ { "name": "http", "nodePort": 30080, "port": 80, "protocol": "TCP", "targetPort": 8080 }, { "name": "https", "nodePort": 30083, "port": 443, "protocol": "TCP", "targetPort": 8080 } ] } }'  > /dev/null 2>&1

echo
echo "ArgoCD is Up and running- go to  http://<hostname>:8080"
echo " \o/ \o/"
echo


# Install Observability/monitoring stack
if [ "$3" ]; then
echo "+-----------------------------------+"
echo -n "Prometheus launching... "
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts  > /dev/null 2>&1
helm repo update  > /dev/null 2>&1
helm upgrade --install prometheus prometheus-community/prometheus --version 19.3.2 -n monitoring --create-namespace \
  --set nodeExporter.hostRootfs=false --wait  > /dev/null 2>&1
echo "done. \o/"

echo
echo "+-----------------------------------+"
echo -n "Grafana launching... "
helm repo add grafana https://grafana.github.io/helm-charts  > /dev/null 2>&1
helm repo update  > /dev/null 2>&1
helm upgrade --install grafana grafana/grafana --version 6.50.5 -n monitoring --wait  > /dev/null 2>&1
# adjust node port / k3d
kubectl patch svc grafana -n monitoring --patch \
  '{"spec": { "type": "NodePort", "ports": [ { "name": "service", "nodePort": 30300, "port": 80, "protocol": "TCP", "targetPort": 3000 } ] } }'  > /dev/null 2>&1
fi
echo "done. \o/"

echo
echo -n "Waiting for demo apps start up... "
dpm=""; while [ -z "$dpm" ]; do dpm=$(kubectl get deploy podinfo 2>/dev/null); done
kubectl wait --for=condition=ready pod -l app=podinfo --timeout=120s  > /dev/null 2>&1
echo " ok."

echo
echo "--------------"
echo " Hello World!"
echo "--------------"
echo "PS: Use <hostname> = localhost or set a hostname and this host's IP in /etc/hosts file on your client machine"
echo
echo "To test demo app:  curl http://<hostname>/hello"
echo
echo "   curl http://<podinfo_ingresshost>/swagger/index.html"
echo
echo "Open in browser  <hostname>:8080  to ArgoCD  -  'admin' password: $(kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode; echo)"
echo "                 <hostname>:3000  to Grafana -  'admin' password: $(kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode; echo)"
echo
