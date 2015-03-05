#!/bin/bash

set -ex

: ${REG_ADDRESS:=regrancher.jamescarlharris.com}
: ${REG_ADDRESS2:=registry.rancherlabs.com}

function ssl(){
    [[ ! -d ./certs/ ]] && mkdir ./certs/
    openssl genrsa -out ./certs/${1}.key 2048
    openssl req -new -x509 -key ./certs/${1}.key -out ./certs/${1}.crt -days 3650 -subj /CN=${1}
}

function killAndRemove(){
    docker stop ${1} 2>/dev/null | echo ${1} stopped.
    docker rm -fv ${1} 2>/dev/null | echo ${1} removed.
}
ssl ${REG_ADDRESS2}

REV_PROXY="nginx-proxy"
killAndRemove ${REV_PROXY}
docker run -d -p 80:80 \
 -p 443:443 \
 -v $(pwd)/certs:/etc/nginx/certs:ro \
 -v /var/run/docker.sock:/tmp/docker.sock \
 --name=${REV_PROXY} \
 jwilder/nginx-proxy

BASE="base-registry"
killAndRemove ${BASE}
docker run -d -p 2000:5000 --name=${BASE} registry


docker build -t localhost:2000/scratch -f scratch.dockerfile .
docker push localhost:2000/scratch
docker build -t localhost:2000/echo .
docker push localhost:2000/echo
docker stop ${BASE}
docker commit ${BASE} rancher/registry
docker rm -f ${BASE}

TEST="test-rancher-registry"
killAndRemove ${TEST}
docker run -d -p 3000:5000 \
--name=${TEST} \
rancher/registry

RANCHER="rancher-registry"
killAndRemove ${RANCHER}
docker run -d --name=${RANCHER} -e VIRTUAL_HOST=${REG_ADDRESS},${REG_ADDRESS2} registry
