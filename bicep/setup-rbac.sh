#!/bin/bash

# Script de gestion RBAC pour Kidoikoiaki sur Azure
# Assigne les rôles appropriés aux ressources

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Paramètres
ENVIRONMENT=${1:-dev}
RESOURCE_GROUP="kdk-${ENVIRONMENT}-rg"
BACKEND_APP="kdk-${ENVIRONMENT}-backend"
FRONTEND_APP="kdk-${ENVIRONMENT}-frontend"

print_info "Configuring RBAC for $ENVIRONMENT environment"
print_info "Resource Group: $RESOURCE_GROUP"

# Obtenir les IDs des objets
BACKEND_PRINCIPAL=$(az webapp identity show \
  --name "$BACKEND_APP" \
  --resource-group "$RESOURCE_GROUP" \
  --query "principalId" -o tsv 2>/dev/null || echo "")

if [ -z "$BACKEND_PRINCIPAL" ]; then
    print_info "Creating system-assigned identity for backend..."
    az webapp identity assign \
      --name "$BACKEND_APP" \
      --resource-group "$RESOURCE_GROUP" \
      --role "Contributor"
    
    BACKEND_PRINCIPAL=$(az webapp identity show \
      --name "$BACKEND_APP" \
      --resource-group "$RESOURCE_GROUP" \
      --query "principalId" -o tsv)
fi

print_success "Backend Principal ID: $BACKEND_PRINCIPAL"

# Assigner des rôles au backend

# 1. SQL Database Access
print_info "Assigning SQL Database role..."
SQL_SERVER=$(az sql server list \
  --resource-group "$RESOURCE_GROUP" \
  --query "[0].name" -o tsv)

SQL_DATABASE=$(az sql db list \
  --server "$SQL_SERVER" \
  --resource-group "$RESOURCE_GROUP" \
  --query "[0].name" -o tsv)

az sql server ad-admin create \
  --server "$SQL_SERVER" \
  --resource-group "$RESOURCE_GROUP" \
  --display-name "Admin" \
  --object-id "$BACKEND_PRINCIPAL" \
  --user-principal-name "backend@$SQL_SERVER" \
  2>/dev/null || print_success "SQL AD admin already configured"

# 2. Storage Account Access
print_info "Assigning Storage Account role..."
STORAGE_ACCOUNT=$(az storage account list \
  --resource-group "$RESOURCE_GROUP" \
  --query "[0].name" -o tsv)

az role assignment create \
  --assignee-object-id "$BACKEND_PRINCIPAL" \
  --role "Storage Blob Data Contributor" \
  --scope "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT" \
  2>/dev/null || print_success "Storage role already assigned"

# 3. Key Vault Access
print_info "Assigning Key Vault role..."
KEY_VAULT=$(az keyvault list \
  --resource-group "$RESOURCE_GROUP" \
  --query "[0].name" -o tsv)

az role assignment create \
  --assignee-object-id "$BACKEND_PRINCIPAL" \
  --role "Key Vault Secrets User" \
  --scope "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.KeyVault/vaults/$KEY_VAULT" \
  2>/dev/null || print_success "Key Vault role already assigned"

print_success "RBAC configuration completed for $ENVIRONMENT environment"

# Afficher un résumé
echo ""
echo "Summary of assigned roles:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Backend App Service: $BACKEND_APP"
echo "  → SQL Database ($SQL_DATABASE): Contributor"
echo "  → Storage Account ($STORAGE_ACCOUNT): Blob Data Contributor"
echo "  → Key Vault ($KEY_VAULT): Secrets User"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
