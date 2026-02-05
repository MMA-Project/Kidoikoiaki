#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    if ! command -v az &> /dev/null; then
        print_error "Azure CLI is not installed. Please install it first."
        exit 1
    fi
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install it first."
        exit 1
    fi
    
    print_success "All prerequisites are installed"
}

# Login to Azure
login_to_azure() {
    print_info "Logging in to Azure..."
    az login
    print_success "Logged in to Azure"
}

# Create resource group
create_resource_group() {
    local rg_name=$1
    local location=$2
    
    print_info "Creating resource group: $rg_name in $location..."
    
    if az group exists --name "$rg_name" | grep -q true; then
        print_success "Resource group $rg_name already exists"
    else
        az group create --name "$rg_name" --location "$location"
        print_success "Created resource group: $rg_name"
    fi
}

# Build and push Docker image
build_and_push_image() {
    local registry=$1
    local image_name=$2
    local dockerfile=$3
    
    print_info "Building Docker image: $image_name..."
    
    docker build -f "$dockerfile" -t "$registry.azurecr.io/$image_name:latest" .
    print_success "Built Docker image"
    
    print_info "Pushing image to ACR..."
    az acr login --name "$registry"
    docker push "$registry.azurecr.io/$image_name:latest"
    print_success "Pushed image to ACR"
}

# Deploy with Bicep
deploy_bicep() {
    local rg_name=$1
    local param_file=$2
    
    print_info "Deploying resources with Bicep using parameters from $param_file..."
    
    az deployment group create \
        --resource-group "$rg_name" \
        --template-file "bicep/main.bicep" \
        --parameters "@$param_file"
    
    print_success "Deployment completed successfully"
}

# Main script
main() {
    if [ $# -lt 1 ]; then
        print_error "Usage: ./deploy.sh <environment> [location]"
        echo "  environment: dev, staging, or prod"
        echo "  location: Azure region (default: westeurope)"
        exit 1
    fi
    
    local environment=$1
    local location=${2:-westeurope}
    local resource_group="kdk-${environment}-rg"
    local param_file="bicep/parameters.${environment}.biceparam"
    
    if [ ! -f "$param_file" ]; then
        print_error "Parameter file not found: $param_file"
        exit 1
    fi
    
    check_prerequisites
    login_to_azure
    create_resource_group "$resource_group" "$location"
    
    # Build and push backend image
    print_info "Building backend image..."
    build_and_push_image "kdkacr" "kidoikoiaki-backend" "Dockerfile"
    
    # Deploy infrastructure
    deploy_bicep "$resource_group" "$param_file"
    
    print_success "Deployment completed for $environment environment"
}

main "$@"
