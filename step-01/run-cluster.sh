#!/bin/bash
K8S_VERSION=1.1.1
if [ $(docker ps -q -f name=etcd | wc -l) == "0" ]
then
  docker run --name=etcd --net=host -d gcr.io/google_containers/etcd:2.2.1 /usr/local/bin/etcd --listen-client-urls=http://127.0.0.1:4001 --advertise-client-urls=http://127.0.0.1:4001 --data-dir=/var/etcd/data
fi
if [ $(docker ps -q -f name=kube | wc -l) == "0" ]
then
  docker run --name=kube \
      --volume=/:/rootfs:ro \
      --volume=/sys:/sys:ro \
      --volume=/dev:/dev \
      --volume=/var/lib/docker/:/var/lib/docker:rw \
      --volume=/var/lib/kubelet/:/var/lib/kubelet:rw \
      --volume=/var/run:/var/run:rw \
      --net=host \
      --pid=host \
      --privileged=true \
      -d \
      gcr.io/google_containers/hyperkube:v${K8S_VERSION} \
      /hyperkube kubelet --containerized --hostname-override="127.0.0.1" --address="0.0.0.0" --api-servers=http://localhost:8080 --config=/etc/kubernetes/manifests
fi
if [ $(docker ps -q -f name=proxy | wc -l) == "0" ]
then
  docker run -d --name=proxy --net=host --privileged gcr.io/google_containers/hyperkube:v${K8S_VERSION} /hyperkube proxy --master=http://127.0.0.1:8080 --v=2
fi
if [ $(docker-machine ssh default 'ls /usr/bin/kubectl | wc -l') == "0" ]
then
  docker-machine ssh default "sudo curl -o /usr/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v${K8S_VERSION}/bin/linux/amd64/kubectl; sudo chmod +x /usr/bin/kubectl"
fi
docker-machine ssh default -t -L 8080:localhost:8080 "cd $PWD ; exec sh"
