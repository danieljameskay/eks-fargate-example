#!/bin/bash

cd logging
kubectl apply -f namespace.yaml
kubectl apply -f configmap.yaml
