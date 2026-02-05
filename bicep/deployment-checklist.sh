#!/bin/bash

# Checklist de déploiement pour Kidoikoiaki sur Azure
# Ce script vous guide à travers toutes les étapes du déploiement

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

CHECKED="[✓]"
UNCHECKED="[ ]"

print_header() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_step() {
    echo -e "${YELLOW}$UNCHECKED $1${NC}"
}

check_step() {
    echo -e "${GREEN}$CHECKED $1${NC}"
}

check_file() {
    if [ -f "$1" ]; then
        check_step "File exists: $1"
        return 0
    else
        print_step "Missing file: $1"
        return 1
    fi
}

check_command() {
    if command -v "$1" &> /dev/null; then
        check_step "$1 is installed"
        return 0
    else
        echo -e "${RED}✗ $1 is NOT installed${NC}"
        return 1
    fi
}

# Main checklist
clear

print_header "📋 Kidoikoiaki Azure Deployment Checklist"

print_header "1️⃣  Prerequisites"

echo "Checking required tools..."
MISSING_TOOLS=0

if ! check_command "az"; then
    MISSING_TOOLS=$((MISSING_TOOLS + 1))
fi

if ! check_command "docker"; then
    MISSING_TOOLS=$((MISSING_TOOLS + 1))
fi

if ! check_command "git"; then
    MISSING_TOOLS=$((MISSING_TOOLS + 1))
fi

if ! check_command "gh"; then
    echo -e "${YELLOW}ℹ️  GitHub CLI is optional but recommended for CI/CD setup${NC}"
fi

if [ $MISSING_TOOLS -gt 0 ]; then
    echo -e "${RED}✗ Missing $MISSING_TOOLS required tools. Please install them first.${NC}"
    exit 1
fi

read -p "All tools installed? Press Enter to continue..."

print_header "2️⃣  Azure Account Setup"

print_step "Logged in to Azure"
read -p "Have you run 'az login'? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    check_step "Logged in to Azure"
else
    echo -e "${YELLOW}Run: az login${NC}"
    exit 1
fi

print_step "Azure Subscription selected"
read -p "Have you selected the correct subscription? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    check_step "Azure Subscription selected"
    SUBSCRIPTION=$(az account show --query name -o tsv)
    echo -e "${GREEN}Current subscription: $SUBSCRIPTION${NC}"
else
    echo -e "${YELLOW}Run: az account set --subscription <name-or-id>${NC}"
    exit 1
fi

print_header "3️⃣  Project Files"

echo "Checking Bicep template files..."

check_file "bicep/main.bicep"
check_file "bicep/resources.bicep"
check_file "bicep/parameters.dev.biceparam"
check_file "bicep/parameters.staging.biceparam"
check_file "bicep/parameters.prod.biceparam"
check_file "Dockerfile"
check_file "Dockerfile.frontend"
check_file "bicepconfig.json"

echo ""
echo "Checking documentation files..."

check_file "bicep/README.md"
check_file "bicep/DOCKER.md"
check_file "bicep/ACR.md"
check_file "bicep/RBAC.md"

echo ""
check_file ".github/workflows/deploy.yml"

print_header "4️⃣  Azure Container Registry"

print_step "ACR created and configured"
read -p "Have you created an Azure Container Registry (ACR)? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    check_step "ACR created"
    
    read -p "Enter ACR name (e.g., kdkacr): " ACR_NAME
    
    if az acr show --name "$ACR_NAME" &> /dev/null; then
        check_step "ACR '$ACR_NAME' exists"
        check_step "Can login to ACR"
    else
        echo -e "${YELLOW}Creating ACR...${NC}"
        az acr create --resource-group kdk-dev-rg --name "$ACR_NAME" --sku Basic
        check_step "ACR created"
    fi
else
    echo -e "${YELLOW}Create ACR:${NC}"
    echo "  az acr create --resource-group kdk-dev-rg --name kdkacr --sku Basic"
    exit 1
fi

print_header "5️⃣  Docker Images"

print_step "Backend Docker image built"
read -p "Have you built and pushed the backend Docker image? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    check_step "Backend Docker image ready"
else
    echo -e "${YELLOW}Build and push:${NC}"
    echo "  docker build -f Dockerfile -t $ACR_NAME.azurecr.io/kidoikoiaki-backend:latest ."
    echo "  docker push $ACR_NAME.azurecr.io/kidoikoiaki-backend:latest"
fi

print_header "6️⃣  Environment Variables"

print_step "Parameters customized"
read -p "Have you customized the parameter files for your environment? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    check_step "Parameters customized"
    
    read -p "Enter environment (dev/staging/prod): " ENVIRONMENT
    
    if [ -f "bicep/parameters.${ENVIRONMENT}.biceparam" ]; then
        check_step "Parameter file exists: bicep/parameters.${ENVIRONMENT}.biceparam"
    else
        echo -e "${RED}Parameter file not found${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}Edit these files:${NC}"
    echo "  bicep/parameters.dev.biceparam"
    echo "  bicep/parameters.staging.biceparam"
    echo "  bicep/parameters.prod.biceparam"
    exit 1
fi

print_header "7️⃣  Resource Group"

RESOURCE_GROUP="kdk-${ENVIRONMENT}-rg"

if az group exists --name "$RESOURCE_GROUP" | grep -q true; then
    check_step "Resource group exists: $RESOURCE_GROUP"
else
    print_step "Resource group needs to be created"
    echo -e "${YELLOW}Creating resource group...${NC}"
    az group create --name "$RESOURCE_GROUP" --location westeurope
    check_step "Resource group created: $RESOURCE_GROUP"
fi

print_header "8️⃣  Bicep Validation"

print_step "Bicep template validated"
read -p "Validate Bicep templates? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Validating...${NC}"
    
    if az deployment group validate \
        --resource-group "$RESOURCE_GROUP" \
        --template-file "bicep/main.bicep" \
        --parameters @"bicep/parameters.${ENVIRONMENT}.biceparam" &> /dev/null; then
        check_step "Bicep template is valid"
    else
        echo -e "${RED}✗ Validation failed!${NC}"
        exit 1
    fi
fi

print_header "9️⃣  Deployment"

print_step "Ready for deployment"

read -p "Deploy to $ENVIRONMENT environment? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Deploying...${NC}"
    echo "This may take 5-10 minutes..."
    
    if az deployment group create \
        --resource-group "$RESOURCE_GROUP" \
        --template-file "bicep/main.bicep" \
        --parameters @"bicep/parameters.${ENVIRONMENT}.biceparam" \
        --parameters "backendImageUri=$ACR_NAME.azurecr.io/kidoikoiaki-backend:latest"; then
        check_step "Deployment completed successfully"
    else
        echo -e "${RED}✗ Deployment failed!${NC}"
        exit 1
    fi
fi

print_header "🔟 Post-Deployment"

read -p "Configure RBAC? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Running RBAC setup...${NC}"
    if [ -f "bicep/setup-rbac.sh" ]; then
        chmod +x bicep/setup-rbac.sh
        ./bicep/setup-rbac.sh "$ENVIRONMENT"
    fi
fi

print_header "✅ Deployment Complete!"

echo -e "${GREEN}Your Kidoikoiaki application has been successfully deployed!${NC}"
echo ""
echo "Next steps:"
echo "1. Verify the deployment in Azure Portal"
echo "2. Check Application Insights for logs"
echo "3. Test the API endpoints"
echo "4. Configure DNS (if applicable)"
echo ""
echo "Useful commands:"
echo "  • View logs:        az webapp log tail --name kdk-${ENVIRONMENT}-backend --resource-group $RESOURCE_GROUP"
echo "  • Show outputs:     az deployment group show --name main --resource-group $RESOURCE_GROUP --query properties.outputs"
echo "  • Delete resources: az group delete --name $RESOURCE_GROUP --yes"
echo ""
