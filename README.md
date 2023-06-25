# Kubeops

A simple and fast way to build your home lab's fully operational k8s cluster, with GitOps practices, observability
stack, Cert manager, demo apps and new resources comming soon.

Requirements:
- 4GB Mem, 2 vCpu 
- Linux / bash (Debian/Ubuntu)
- Docker/containerd ready


### Getting started
Clone the repo and using a Linux distro with bash shell, run:


export GIT_TOKEN="<your Github token>"     /* or set it value in 'infra/scripts/autopilot-bootstrap.sh' */

./infra/build_k8s.sh <k3d|kind>    /* param.1: set the platform.
