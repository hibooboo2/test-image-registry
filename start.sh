#!/bin/bash

function ssl(){
    [[ ! -d ./certs/ ]] && mkdir ./certs/
    openssl genrsa -out ./certs/${1}.key 2048
    openssl req -new -x509 -key ./certs/${1}.key -out ./certs/${1}.crt -days 3650 -subj /CN=${1}
}

#ssl ${REG_ADDRESS2}

REV_PROXY="nginx-proxy"
killAndRemove ${REV_PROXY}
docker run -d -p 80:80 \
 -p 443:443 \
 -v $(pwd)/certs:/etc/nginx/certs:ro \
 -v ${HOME}/sandbox/docker-registry.htpasswd:/auth/docker-registry.htpasswd
 --name=${REV_PROXY} \
 nginx
 
