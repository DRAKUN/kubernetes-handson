#!/bin/bash
proxy=http://10.0.0.18:3128
export http_proxy=$proxy
export https_proxy=$proxy
export HTTP_PROXY=$proxy
export HTTPS_PROXY=$proxy
cd ../kubernetes-vagrant-coreos-cluster/
vagrant up
cd ../step-01
