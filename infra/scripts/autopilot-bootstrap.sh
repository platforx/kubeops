
# Env vars. required by argocd-autopilot to access the gitops repo
#export GIT_TOKEN="<your Git repo token>"
export GIT_REPO="https://github.com/platforx/kubeops.git"


# 1st initialization
#argocd-autopilot repo bootstrap --provider gitlab

echo "Restoring gitops state..."
argocd-autopilot repo bootstrap --recover

# Add a Project and a demo Application
#echo "Adding ArgoCD Autopilot demo App..."
#argocd-autopilot project create testing
#argocd-autopilot app create hello-world --type kustomize --app github.com/argoproj-labs/argocd-autopilot/examples/demo-app/ -p testing
