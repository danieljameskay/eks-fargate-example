#!/bin/bash

kubectl patch deployment coredns \
      --namespace kube-system \
      --type=json -p='[{"op": "remove", "path": "/spec/template/metadata/annotations", "value": "eks.amazonaws.com/compute-type"}]' \

kubectl rollout restart -n kube-system deployment coredns