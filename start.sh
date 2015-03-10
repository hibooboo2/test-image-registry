#!/bin/bash

set -e

cd $(dirname $0)

function ssl(){
    [[ ! -d ./certs/ ]] && mkdir ./certs/
    openssl genrsa -out ./certs/${1}.key 2048
    openssl req -new -x509 -key ./certs/${1}.key -out ./certs/${1}.crt -days 3650 -subj /CN=${1}
}

function killAndRemove(){
    docker stop ${1} | echo ${1} stopped.
    docker rm -fv ${1} | echo ${1} removed.
}
#ssl ${REG_ADDRESS2}



REV_PROXY="nginx-proxy"
CONF=$(pwd)/nginx.conf
PROXY=$(pwd)/docker-registry.conf
CERTS=$(pwd)/certs
PASSWORDS=$(pwd)/.htpasswd
killAndRemove ${REV_PROXY}
sleep 2
docker run -d -p 80:80 \
 -p 443:443 \
 -v ${pwd}:/src \
 -v ${CERTS}:/etc/nginx/certs:ro \
 -v ${PASSWORDS}:/etc/nginx/.htpasswd \
 -v ${CONF}:/etc/nginx/nginx.conf \
 -v ${PROXY}:/etc/nginx/docker-registry.conf \
 --link rancher-registry:registry \
 --name=${REV_PROXY} \
 nginx

