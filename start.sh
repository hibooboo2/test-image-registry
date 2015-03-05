#!/bin/bash

set -e

openssl genrsa -out ./certs/boot2docker.key 2048
openssl req -new -x509 -key ./certs/boot2docker.key -out ./certs/boot2docker.crt -days 3650 -subj /CN=boot2docker

openssl genrsa -out ./certs/hi.boot2docker.key 2048
openssl req -new -x509 -key ./certs/hi.boot2docker.key -out ./certs/hi.boot2docker.crt -days 3650 -subj /CN=boot2docker

docker stop nginx-proxy 2>/dev/null | echo Proxy stopped.
docker rm -fv nginx-proxy 2>/dev/null | echo Proxy removed.
docker run -d -p 80:80 \
 -p 443:443 \
 -v $(pwd)/certs:/etc/nginx/certs \
 -v /var/run/docker.sock:/tmp/docker.sock \
 --name=nginx-proxy \
 jwilder/nginx-proxy

docker build -t rancher-test-registry .
docker stop rancher-registry 2>/dev/null | echo Registry stopped.
docker rm -f rancher-registry 2>/dev/null | echo Registry removed.
docker run -d --name=rancher-registry -e VIRTUAL_HOST=boot2docker rancher-test-registry
