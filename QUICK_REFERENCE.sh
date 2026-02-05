#!/bin/bash

# Kidoikoiaki - Quick Command Reference
# Source this file or copy commands as needed

# ═══════════════════════════════════════════════════════════════
# 🎯 QUICK START
# ═══════════════════════════════════════════════════════════════

# Deploy in 3 commands
az login
az acr create --resource-group kdk-dev-rg --name kdkacr --sku Basic
./bicep/deploy.sh dev

# ═══════════════════════════════════════════════════════════════
# 🐳 DOCKER COMMANDS
# ═══════════════════════════════════════════════════════════════

# Build backend image
docker build -f Dockerfile -t kdkacr.azurecr.io/kidoikoiaki-backend:latest .

# Build frontend image
docker build -f Dockerfile.frontend -t kdkacr.azurecr.io/kidoikoiaki-frontend:latest .

# Push to ACR
az acr login --name kdkacr
docker push kdkacr.azurecr.io/kidoikoiaki-backend:latest
docker push kdkacr.azurecr.io/kidoikoiaki-frontend:latest

# View images in ACR
az acr repository list --name kdkacr

# ═══════════════════════════════════════════════════════════════
# ☁️  BICEP DEPLOYMENT
# ═══════════════════════════════════════════════════════════════

# Validate templates
az deployment group validate \
  --resource-group kdk-dev-rg \
  --template-file bicep/main.bicep \
  --parameters @bicep/parameters.dev.biceparam

# Deploy infrastructure
az deployment group create \
  --resource-group kdk-dev-rg \
  --template-file bicep/main.bicep \
  --parameters @bicep/parameters.dev.biceparam

# See deployment outputs
az deployment group show \
  --resource-group kdk-dev-rg \
  --name main \
  --query "properties.outputs"

# ═══════════════════════════════════════════════════════════════
# 📊 VIEW RESOURCES
# ═══════════════════════════════════════════════════════════════

# List resource groups
az group list --output table

# List resources in group
az resource list --resource-group kdk-dev-rg --output table

# View App Service
az webapp list --resource-group kdk-dev-rg --output table

# View SQL Server
az sql server list --resource-group kdk-dev-rg --output table

# View Storage Account
az storage account list --resource-group kdk-dev-rg --output table

# ═══════════════════════════════════════════════════════════════
# 📋 VIEW LOGS
# ═══════════════════════════════════════════════════════════════

# Backend App logs
az webapp log tail --name kdk-dev-backend --resource-group kdk-dev-rg

# Deployment logs
az deployment group show \
  --resource-group kdk-dev-rg \
  --name main \
  --query "properties.error"

# ═══════════════════════════════════════════════════════════════
# 🔐 SECURITY
# ═══════════════════════════════════════════════════════════════

# Setup RBAC
./bicep/setup-rbac.sh dev

# Setup GitHub Secrets
./bicep/setup-github-secrets.sh

# View Key Vault secrets
az keyvault secret list --vault-name kdk-kv

# Get SQL password from Key Vault
az keyvault secret show \
  --vault-name kdk-kv \
  --name "sql-admin-password" \
  --query "value" -o tsv

# ═══════════════════════════════════════════════════════════════
# 🧹 CLEANUP
# ═══════════════════════════════════════════════════════════════

# Delete resource group (and all resources)
az group delete --name kdk-dev-rg --yes

# Delete specific resource
az resource delete \
  --resource-group kdk-dev-rg \
  --resource-type Microsoft.Web/sites \
  --name kdk-dev-backend

# ═══════════════════════════════════════════════════════════════
# 🛠️  MAKE COMMANDS
# ═══════════════════════════════════════════════════════════════

# Install dependencies
make install

# Development
make dev

# Build Docker images
make docker-build ENV=dev
make docker-build-frontend ENV=dev

# Push to registry
make docker-push ENV=dev

# Bicep deployment
make bicep-validate ENV=dev
make bicep-deploy ENV=dev

# View logs
make bicep-logs ENV=dev

# Delete resources
make bicep-destroy ENV=dev

# ═══════════════════════════════════════════════════════════════
# 📝 SCRIPT COMMANDS
# ═══════════════════════════════════════════════════════════════

# Run deployment script
chmod +x bicep/deploy.sh
./bicep/deploy.sh dev

# Interactive checklist
chmod +x bicep/deployment-checklist.sh
./bicep/deployment-checklist.sh

# Setup RBAC
chmod +x bicep/setup-rbac.sh
./bicep/setup-rbac.sh dev

# Setup GitHub CI/CD
chmod +x bicep/setup-github-secrets.sh
./bicep/setup-github-secrets.sh

# ═══════════════════════════════════════════════════════════════
# 🌍 ENVIRONMENT VARIABLES
# ═══════════════════════════════════════════════════════════════

# Set Azure subscription
az account set --subscription "subscription-id-or-name"

# List subscriptions
az account list --output table

# Show current subscription
az account show --output table

# ═══════════════════════════════════════════════════════════════
# 🔧 MANAGEMENT
# ═══════════════════════════════════════════════════════════════

# Restart App Service
az webapp restart --name kdk-dev-backend --resource-group kdk-dev-rg

# Scale App Service
az appservice plan update \
  --name kdk-dev-app-plan \
  --resource-group kdk-dev-rg \
  --sku Standard

# Stop App Service
az webapp stop --name kdk-dev-backend --resource-group kdk-dev-rg

# Start App Service
az webapp start --name kdk-dev-backend --resource-group kdk-dev-rg

# ═══════════════════════════════════════════════════════════════
# 📊 MONITORING
# ═══════════════════════════════════════════════════════════════

# View App Insights metrics
az monitor metrics list \
  --resource /subscriptions/{id}/resourceGroups/kdk-dev-rg/providers/Microsoft.Insights/components/kdk-dev-insights \
  --interval PT1M \
  --metric "RequestsPerSecond"

# View alerts
az monitor alert show \
  --resource-group kdk-dev-rg

# ═══════════════════════════════════════════════════════════════
# 💰 COST MANAGEMENT
# ═══════════════════════════════════════════════════════════════

# Estimate costs
# Use Azure Pricing Calculator:
# https://azure.microsoft.com/en-us/pricing/calculator/

# View current costs (Azure Portal)
# Subscriptions → Cost Management → Cost Analysis

# ═══════════════════════════════════════════════════════════════
# 📚 DOCUMENTATION
# ═══════════════════════════════════════════════════════════════

# View quick reference
cat BICEP_SUMMARY.md

# View file listing
cat FILES_CREATED.md

# View main guide
cat bicep/README.md

# View deployment guide
cat bicep/DEPLOYMENT.md

# View index
cat bicep/INDEX.md
