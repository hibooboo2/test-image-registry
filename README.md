#Rancher Test Image Registry

Purpose - create container that when run starts a registry for use with cattle
integration tests.

Usage

```
docker build -t rancher-test-registry .
docker run -d rancher-test-registry

```
