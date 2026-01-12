#!/bin/bash

echo "=== Installing NGINX Ingress Controller ==="
echo ""

# Detect environment
if kubectl config current-context | grep -q "minikube"; then
    echo "Detected Minikube environment"
    echo "Enabling ingress addon..."
    minikube addons enable ingress
    echo ""
    echo "Waiting for ingress controller to be ready..."
    kubectl wait --namespace ingress-nginx \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/component=controller \
        --timeout=120s 2>/dev/null || true
else
    echo "Detected Docker Desktop / other environment"
    echo "Installing NGINX Ingress Controller..."
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.5/deploy/static/provider/cloud/deploy.yaml
    echo ""
    echo "Waiting for ingress controller to be ready..."
    kubectl wait --namespace ingress-nginx \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/component=controller \
        --timeout=180s
fi

echo ""
echo "=== Ingress Controller Installed ==="
echo ""
echo "Verify with: kubectl get pods -n ingress-nginx"
echo "Now run: ./deploy.sh"
