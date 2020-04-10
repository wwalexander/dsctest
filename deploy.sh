#!/usr/bin/env sh

# Start minikube if it isn't already running
minikube status --format='' || minikube start
# Make `docker build` target VM's docker daemon
eval $(minikube docker-env)
docker build --tag=fizzbuzz .
minikube kubectl -- apply -f service.yaml -f nodeport.yaml -f  deployment.yaml
