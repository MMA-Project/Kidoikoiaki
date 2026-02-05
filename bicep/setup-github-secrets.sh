#!/bin/bash

# Script de configuration des secrets GitHub pour le déploiement Azure
# Ce script vous aide à configurer les secrets nécessaires pour GitHub Actions

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Configuration des Secrets GitHub pour Kidoikoiaki${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Vérifier si Azure CLI est installé
if ! command -v az &> /dev/null; then
    echo -e "${RED}❌ Azure CLI n'est pas installé${NC}"
    exit 1
fi

# Vérifier si GitHub CLI est installé
if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI n'est pas installé${NC}"
    exit 1
fi

# Obtenir l'abonnement Azure actuellement actif
SUBSCRIPTION_ID=$(az account show --query "id" -o tsv)
TENANT_ID=$(az account show --query "tenantId" -o tsv)

echo -e "${BLUE}ℹ️  Abonnement Azure: $SUBSCRIPTION_ID${NC}"
echo -e "${BLUE}ℹ️  Tenant ID: $TENANT_ID${NC}"
echo ""

# Créer une identité managée (Federated Identity)
echo -e "${BLUE}Étape 1: Créer l'application Azure AD (si nécessaire)${NC}"
echo "Appuyez sur Entrée pour continuer..."
read

APP_NAME="KidoikoiakiCI"
APP_REGISTRATION=$(az ad app create --display-name "$APP_NAME" 2>/dev/null || echo "exists")

if [ "$APP_REGISTRATION" != "exists" ]; then
    CLIENT_ID=$(echo $APP_REGISTRATION | jq -r '.appId')
    echo -e "${GREEN}✓ Application créée: $CLIENT_ID${NC}"
else
    CLIENT_ID=$(az ad app list --filter "displayName eq '$APP_NAME'" --query "[0].appId" -o tsv)
    echo -e "${GREEN}✓ Application existante: $CLIENT_ID${NC}"
fi

# Créer un principal de service
echo ""
echo -e "${BLUE}Étape 2: Créer le principal de service${NC}"
PRINCIPAL_ID=$(az ad sp create-for-rbac --name "$APP_NAME" --role Contributor \
  --scopes "/subscriptions/$SUBSCRIPTION_ID" 2>/dev/null | jq -r '.objectId' || \
  az ad sp list --display-name "$APP_NAME" --query "[0].id" -o tsv)

echo -e "${GREEN}✓ Principal ID: $PRINCIPAL_ID${NC}"

# Configurer la fédération d'identité pour GitHub
echo ""
echo -e "${BLUE}Étape 3: Configurer la fédération pour GitHub${NC}"

# Lire les informations du repository
REPO_OWNER=$(gh repo view --json owner --jq '.owner.login')
REPO_NAME=$(gh repo view --json name --jq '.name')

echo -e "${BLUE}ℹ️  Utilisateur GitHub: $REPO_OWNER${NC}"
echo -e "${BLUE}ℹ️  Repo: $REPO_NAME${NC}"
echo ""

# Créer les credentials fédérés
CREDENTIAL_NAME="github-$REPO_OWNER-$REPO_NAME"

cat > /tmp/federated-credential.json <<EOF
{
  "name": "$CREDENTIAL_NAME",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:$REPO_OWNER/$REPO_NAME:ref:refs/heads/main",
  "description": "GitHub Actions federation for Kidoikoiaki",
  "audiences": ["api://AzureADTokenExchange"]
}
EOF

az ad app federated-credential create \
  --id $CLIENT_ID \
  --parameters /tmp/federated-credential.json \
  || echo -e "${GREEN}✓ Credential fédéré déjà existant${NC}"

echo -e "${GREEN}✓ Fédération d'identité configurée${NC}"

# Créer les secrets GitHub
echo ""
echo -e "${BLUE}Étape 4: Ajouter les secrets à GitHub${NC}"
echo ""

echo "Les secrets suivants vont être ajoutés à votre repository GitHub:"
echo "  - AZURE_CLIENT_ID: $CLIENT_ID"
echo "  - AZURE_TENANT_ID: $TENANT_ID"
echo "  - AZURE_SUBSCRIPTION_ID: $SUBSCRIPTION_ID"
echo ""

read -p "Continuer? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    gh secret set AZURE_CLIENT_ID --body "$CLIENT_ID"
    echo -e "${GREEN}✓ AZURE_CLIENT_ID défini${NC}"
    
    gh secret set AZURE_TENANT_ID --body "$TENANT_ID"
    echo -e "${GREEN}✓ AZURE_TENANT_ID défini${NC}"
    
    gh secret set AZURE_SUBSCRIPTION_ID --body "$SUBSCRIPTION_ID"
    echo -e "${GREEN}✓ AZURE_SUBSCRIPTION_ID défini${NC}"
    
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ Configuration terminée!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "Prochaines étapes:"
    echo "1. Le CI/CD se déclenchera automatiquement au prochain push"
    echo "2. Vérifiez les Actions dans GitHub pour voir le statut du déploiement"
    echo "3. Les images Docker seront pushées vers Azure Container Registry"
    echo "4. Les ressources Azure seront créées/mises à jour"
    echo ""
else
    echo "Annulé"
fi

rm -f /tmp/federated-credential.json
