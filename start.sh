#!/bin/bash

set -ex

: ${REG_ADDRESS:=regrancher.jamescarlharris.com}
: ${REG_ADDRESS2:=registry.rancherlabs.com}

function ssl(){
    [[ ! -d ./certs/ ]] && mkdir ./certs/
    openssl genrsa -out ./certs/${1}.key 2048
    openssl req -new -x509 -key ./certs/${1}.key -out ./certs/${1}.crt -days 3650 -subj /CN=${1}
}

ssl ${REG_ADDRESS2}

docker stop nginx-proxy 2>/dev/null | echo Proxy stopped.
docker rm -fv nginx-proxy 2>/dev/null | echo Proxy removed.
docker run -d -p 80:80 \
 -p 443:443 \
 -v $(pwd)/certs:/etc/nginx/certs:ro \
 -v /var/run/docker.sock:/tmp/docker.sock \
 --name=nginx-proxy \
 jwilder/nginx-proxy


docker build -t rancher-test-registry .


docker stop rancher-registry 2>/dev/null | echo Registry stopped.
docker rm -f rancher-registry 2>/dev/null | echo Registry removed.
docker run -d --name=rancher-registry -e VIRTUAL_HOST=${REG_ADDRESS},${REG_ADDRESS2} registry
