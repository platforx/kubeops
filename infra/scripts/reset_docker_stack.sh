#!/bin/bash

# Docker clean
echo -n "Docker pruning... "
docker stop $(docker ps -aq)  > /dev/null 2>&1 || :
docker rm $(docker ps -aq) > /dev/null 2>&1 || :
docker rmi -f $(docker images -q) > /dev/null 2>&1 || :
docker volume rm $(docker volume ls -q) > /dev/null 2>&1 || :
docker network rm $(docker network ls -q) > /dev/null 2>&1 || :
docker system prune --all --volumes --force > /dev/null 2>&1 || :
rm -rf ~/.kube/config
echo "done!"
