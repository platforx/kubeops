#!/bin/bash

set -eux

_PLATF=$1


cd infra

[ -z "$_PLATF" ] && echo "Error: Missing platform... " && exit

./scripts/build-environment.sh $_PLATF cluster-1 false

cd -
