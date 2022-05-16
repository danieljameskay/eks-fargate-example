#!/bin/bash
# This create script must return a json as an output. Therefore, we suspend the kubectl output and return a static json.
# See: https://registry.terraform.io/providers/scottwinkler/shell/latest/docs/resources/shell_script_resource

kubectl patch deployment coredns \
      --namespace kube-system \
      --type=json -p='[{"op": "remove", "path": "/spec/template/metadata/annotations", "value": "eks.amazonaws.com/compute-type"}]' \

kubectl rollout restart -n kube-system deployment coredns

echo "The CoreDNS Deployment has been patched"