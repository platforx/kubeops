#!/bin/bash

# https://docs.docker.com/engine/install/debian/

curl -fsSL https://get.docker.com | bash
systemctl enable docker
systemctl restart docker

