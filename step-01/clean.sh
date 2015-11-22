#!/bin/bash
docker rm -f k8s-registry_mirror k8s-master
for node in $(docker ps -q -f name=k8s-node)
do
  docker rm -f $node
done
