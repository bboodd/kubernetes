#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

RELEASE_NAME="k8s-practice"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_banner() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   Kubernetes Practice Cleanup          ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""
}

show_usage() {
    echo "Usage: $0 [option]"
    echo ""
    echo "Options:"
    echo "  helm      Cleanup Helm release"
    echo "  manifest  Cleanup raw Kubernetes manifests"
    echo "  all       Cleanup both (auto-detect)"
    echo "  -h        Show this help message"
    echo ""
    echo "If no option is provided, interactive menu will be shown."
}

cleanup_helm() {
    echo -e "${YELLOW}Cleaning up Helm release...${NC}"

    if helm status ${RELEASE_NAME} &>/dev/null; then
        echo "Uninstalling Helm release: ${RELEASE_NAME}"
        helm uninstall ${RELEASE_NAME}
        echo -e "${GREEN}Helm release uninstalled.${NC}"
    else
        echo -e "${YELLOW}No Helm release '${RELEASE_NAME}' found.${NC}"
    fi
}

cleanup_manifest() {
    echo -e "${YELLOW}Cleaning up raw manifests...${NC}"

    echo "  - Deleting Ingress..."
    kubectl delete -f k8s/ingress.yaml --ignore-not-found 2>/dev/null || true

    echo "  - Deleting Monitoring..."
    kubectl delete -f k8s/monitoring/ --ignore-not-found 2>/dev/null || true

    echo "  - Deleting ELK Stack..."
    kubectl delete -f k8s/elk/ --ignore-not-found 2>/dev/null || true

    echo "  - Deleting Next.js..."
    kubectl delete -f k8s/next.yaml --ignore-not-found 2>/dev/null || true

    echo "  - Deleting Spring Boot..."
    kubectl delete -f k8s/spring.yaml --ignore-not-found 2>/dev/null || true

    echo "  - Deleting PostgreSQL..."
    kubectl delete -f k8s/postgres.yaml --ignore-not-found 2>/dev/null || true

    echo "  - Deleting Secrets..."
    kubectl delete -f k8s/secrets.yaml --ignore-not-found 2>/dev/null || true

    echo -e "${GREEN}Raw manifests cleaned up.${NC}"
}

cleanup_all() {
    echo -e "${YELLOW}Auto-detecting and cleaning up all resources...${NC}"
    echo ""

    # Try Helm first
    if helm status ${RELEASE_NAME} &>/dev/null; then
        cleanup_helm
    fi

    # Then clean up any remaining manifest resources
    cleanup_manifest
}

select_cleanup() {
    echo "Select cleanup method:"
    echo ""
    echo "  1) Helm       - Uninstall Helm release"
    echo "  2) Manifest   - Delete raw Kubernetes manifests"
    echo "  3) All        - Auto-detect and clean everything"
    echo ""
    read -p "Enter choice [1-3]: " choice

    case $choice in
        1) CLEANUP_METHOD="helm" ;;
        2) CLEANUP_METHOD="manifest" ;;
        3) CLEANUP_METHOD="all" ;;
        *)
            echo -e "${RED}Invalid choice${NC}"
            exit 1
            ;;
    esac
}

print_post_cleanup() {
    echo ""
    echo -e "${GREEN}=== Cleanup Complete ===${NC}"
    echo ""
    echo "Remaining resources:"
    kubectl get pods 2>/dev/null | grep -E "(spring|next|postgres|elastic|kibana|filebeat|prometheus|grafana)" || echo "  No application pods found."
    echo ""
    echo "Optional cleanup commands:"
    echo "  Remove Docker images:  docker rmi spring-app:latest next-app:latest"
    echo "  Remove all PVCs:       kubectl delete pvc --all"
    echo "  Remove all PVs:        kubectl delete pv --all"
    echo ""
}

# Main
print_banner

# Parse arguments
case "${1:-}" in
    helm)
        CLEANUP_METHOD="helm"
        ;;
    manifest)
        CLEANUP_METHOD="manifest"
        ;;
    all)
        CLEANUP_METHOD="all"
        ;;
    -h|--help)
        show_usage
        exit 0
        ;;
    "")
        select_cleanup
        ;;
    *)
        echo -e "${RED}Unknown option: $1${NC}"
        show_usage
        exit 1
        ;;
esac

case $CLEANUP_METHOD in
    helm)
        cleanup_helm
        ;;
    manifest)
        cleanup_manifest
        ;;
    all)
        cleanup_all
        ;;
esac

print_post_cleanup
