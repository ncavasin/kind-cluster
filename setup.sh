#!/bin/bash

# Create the cluster
if ! kind create cluster --config cluster.yaml; then
    exit 1
fi;

# Add metrics service 
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
sleep 10
# Install metrics service
helm upgrade --install metrics-server metrics-server/metrics-server

# Add kubernetes-dashboard repository
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
sleep 10
# Deploy a Helm Release named "kubernetes-dashboard" using the kubernetes-dashboard chart
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard \
    --create-namespace --namespace kubernetes-dashboard \
    --set protocolHttp=true \
    --set metricsScraper.enabled=true

# Add traefik
helm repo add traefik https://traefik.github.io/charts
sleep 10
# Install traefik
helm upgrade --install -f values/traefik/values.yaml traefik traefik/traefik

# Install cert-manager CRD
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.1/cert-manager.crds.yaml
sleep 10
# Add cert-manager
helm repo add jetstack https://charts.jetstack.io
sleep 10
# Install cert-manager
helm install cert-manager --namespace cert-manager --version v1.13.1 jetstack/cert-manager

