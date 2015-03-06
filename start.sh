#!/bin/bash

set -ex

: ${REG_ADDRESS:=example.com}
: ${REG_ADDRESS2:=example.io}

function ssl(){
    [[ ! -d ./certs/ ]] && mkdir ./certs/
    openssl genrsa -out ./certs/${1}.key 2048
    openssl req -new -x509 -key ./certs/${1}.key -out ./certs/${1}.crt -days 3650 -subj /CN=${1}
}

function killAndRemove(){
    docker stop ${1} 2>/dev/null | echo ${1} stopped.
    docker rm -fv ${1} 2>/dev/null | echo ${1} removed.
}

function buildAndPush(){
    docker build -t ${2} -f ${1} .
    docker push ${2}
}

#ssl ${REG_ADDRESS2}

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

PUSHTO="localhost:2000"
buildAndPush Loopfile ${PUSHTO}/rancher/loop
buildAndPush Dockerfile ${PUSHTO}/echo
buildAndPush scratch.dockerfile ${PUSHTO}/echo:scratch
buildAndPush scratch.dockerfile ${PUSHTO}/rancher/loop:scratch

docker stop ${BASE}
docker commit ${BASE} rancher/test-registry
docker commit ${BASE} ${PUSHTO}/rancher/test-registry
docker rm -f ${BASE}


RANCHER="rancher-registry"
killAndRemove ${RANCHER}
docker run -d --name=${RANCHER} -p 2000:5000 rancher/test-registry
docker push ${PUSHTO}/rancher/test-registry

docker stop ${RANCHER}
docker commit ${RANCHER} ${REG_ADDRESS2}/rancher/test-registry

killAndRemove ${RANCHER}
docker run -d --name=${RANCHER} -e VIRTUAL_HOST=${REG_ADDRESS},${REG_ADDRESS2} ${REG_ADDRESS2}/rancher/test-registry
