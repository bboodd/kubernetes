#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

RELEASE_NAME="k8s-practice"
CHART_PATH="./helm/k8s-practice"
NAMESPACE="default"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_banner() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   Kubernetes Practice Deployment       ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""
}

show_usage() {
    echo "Usage: $0 [option]"
    echo ""
    echo "Options:"
    echo "  helm      Deploy using Helm chart"
    echo "  manifest  Deploy using raw Kubernetes manifests"
    echo "  -h        Show this help message"
    echo ""
    echo "If no option is provided, interactive menu will be shown."
}

check_ingress() {
    echo -e "${YELLOW}[0/4] Checking Ingress Controller...${NC}"
    if ! kubectl get ingressclass nginx &>/dev/null; then
        echo ""
        echo -e "${RED}WARNING: NGINX Ingress Controller not found!${NC}"
        echo "Install it with: ./setup-ingress.sh"
        echo ""
        read -p "Continue anyway? (y/N): " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            echo "Aborted."
            exit 1
        fi
    else
        echo -e "${GREEN}NGINX Ingress Controller found.${NC}"
    fi
}

build_images() {
    echo ""
    echo -e "${YELLOW}[1/4] Building Spring Boot image...${NC}"
    docker build -t spring-app:latest ./spring-app

    echo ""
    echo -e "${YELLOW}[2/4] Building Next.js image...${NC}"
    docker build -t next-app:latest ./next-app
}

deploy_helm() {
    echo ""
    echo -e "${BLUE}=== Deploying with Helm ===${NC}"

    if ! command -v helm &>/dev/null; then
        echo -e "${RED}ERROR: Helm is not installed!${NC}"
        echo "Install it from: https://helm.sh/docs/intro/install/"
        exit 1
    fi

    SECRETS_FILE=""
    if [ -f "${CHART_PATH}/values-secret.yaml" ]; then
        SECRETS_FILE="-f ${CHART_PATH}/values-secret.yaml"
        echo ""
        echo -e "${YELLOW}[3/4] Using custom secrets from values-secret.yaml${NC}"
    else
        echo ""
        echo -e "${YELLOW}[3/4] Using default secrets (create values-secret.yaml for custom values)${NC}"
    fi

    echo ""
    echo -e "${YELLOW}[4/4] Deploying with Helm...${NC}"
    if helm status ${RELEASE_NAME} -n ${NAMESPACE} &>/dev/null; then
        echo "Upgrading existing release..."
        helm upgrade ${RELEASE_NAME} ${CHART_PATH} -n ${NAMESPACE} ${SECRETS_FILE} --wait --timeout 10m
    else
        echo "Installing new release..."
        helm install ${RELEASE_NAME} ${CHART_PATH} -n ${NAMESPACE} ${SECRETS_FILE} --wait --timeout 10m
    fi

    echo ""
    echo -e "${GREEN}=== Helm Deployment Complete ===${NC}"
    echo ""
    echo "Release: ${RELEASE_NAME}"
    echo "Namespace: ${NAMESPACE}"
    echo ""
    echo "Helm commands:"
    echo "  Status:     helm status ${RELEASE_NAME}"
    echo "  Uninstall:  helm uninstall ${RELEASE_NAME}"
    echo "  Upgrade:    helm upgrade ${RELEASE_NAME} ${CHART_PATH}"
}

deploy_manifest() {
    echo ""
    echo -e "${BLUE}=== Deploying with Raw Manifests ===${NC}"

    # Check secrets
    if [ ! -f "k8s/secrets.yaml" ]; then
        echo ""
        echo -e "${RED}ERROR: k8s/secrets.yaml not found!${NC}"
        echo "Create it from the example:"
        echo "  cp k8s/secrets.yaml.example k8s/secrets.yaml"
        echo "Then edit with your values."
        exit 1
    fi

    echo ""
    echo -e "${YELLOW}[3/4] Applying Kubernetes manifests...${NC}"

    echo "  - Applying secrets..."
    kubectl apply -f k8s/secrets.yaml

    echo "  - Applying PostgreSQL..."
    kubectl apply -f k8s/postgres.yaml

    echo "  - Applying Spring Boot..."
    kubectl apply -f k8s/spring.yaml

    echo "  - Applying Next.js..."
    kubectl apply -f k8s/next.yaml

    echo "  - Applying ELK Stack..."
    kubectl apply -f k8s/elk/

    echo "  - Applying Monitoring..."
    kubectl apply -f k8s/monitoring/

    echo "  - Applying Ingress..."
    kubectl apply -f k8s/ingress.yaml

    echo ""
    echo -e "${YELLOW}[4/4] Waiting for pods to be ready...${NC}"
    kubectl wait --for=condition=ready pod -l app=postgres --timeout=120s 2>/dev/null || true
    kubectl wait --for=condition=ready pod -l app=spring-app --timeout=120s 2>/dev/null || true
    kubectl wait --for=condition=ready pod -l app=next-app --timeout=120s 2>/dev/null || true

    echo ""
    echo -e "${GREEN}=== Manifest Deployment Complete ===${NC}"
    echo ""
    echo "Kubectl commands:"
    echo "  Status:  kubectl get pods"
    echo "  Logs:    kubectl logs -l app=spring-app"
    echo "  Delete:  ./cleanup.sh manifest"
}

print_access_urls() {
    echo ""
    echo -e "${BLUE}Access URLs:${NC}"
    echo "  App:        http://localhost/"
    echo "  API:        http://localhost/api/"
    echo "  Grafana:    http://grafana.localhost/"
    echo "  Prometheus: http://prometheus.localhost/"
    echo "  Kibana:     http://kibana.localhost/"
    echo ""
    echo "Check resources:"
    echo "  kubectl get pods"
    echo "  kubectl get svc"
    echo "  kubectl get ingress"
    echo ""
}

select_deployment() {
    echo "Select deployment method:"
    echo ""
    echo "  1) Helm       - Recommended for production-like setup"
    echo "  2) Manifest   - Raw Kubernetes YAML files"
    echo ""
    read -p "Enter choice [1-2]: " choice

    case $choice in
        1) DEPLOY_METHOD="helm" ;;
        2) DEPLOY_METHOD="manifest" ;;
        *)
            echo -e "${RED}Invalid choice${NC}"
            exit 1
            ;;
    esac
}

# Main
print_banner

# Parse arguments
case "${1:-}" in
    helm)
        DEPLOY_METHOD="helm"
        ;;
    manifest)
        DEPLOY_METHOD="manifest"
        ;;
    -h|--help)
        show_usage
        exit 0
        ;;
    "")
        select_deployment
        ;;
    *)
        echo -e "${RED}Unknown option: $1${NC}"
        show_usage
        exit 1
        ;;
esac

check_ingress
build_images

case $DEPLOY_METHOD in
    helm)
        deploy_helm
        ;;
    manifest)
        deploy_manifest
        ;;
esac

print_access_urls
