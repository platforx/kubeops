#!/bin/bash
cd infra
./scripts/build-environment.sh k3d cluster-1 false
cd -
