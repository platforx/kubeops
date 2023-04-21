# doc- https://www.suse.com/c/rancher_blog/introduction-to-k3d-run-k3s-in-docker/ 

k3d cluster create $1 --servers 1 --agents $2 -p "80:80@loadbalancer" -p "443:443@loadbalancer" \
                                              -p "8080:30080@agent:0,1" -p "3000:30300@agent:0,1"
                                              #--k3s-arg "--disable=traefik@server:0"
