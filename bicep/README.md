# 🚀 Guide de Déploiement Bicep - Kidoikoiaki

Ce guide explique comment déployer l'application Kidoikoiaki sur Azure en utilisant les templates Bicep.

## 📋 Prérequis

- **Azure CLI** (installé et configuré)
- **Docker** (pour build les images)
- **Azure Subscription** (avec les permissions nécessaires)
- **Azure Container Registry (ACR)** (pour héberger les images Docker)

### Installation des outils

```bash
# Installer Azure CLI
brew install azure-cli  # macOS
# ou sudo apt-get install azure-cli  # Linux

# Installer Docker
brew install docker  # macOS
# ou suivre les instructions officielles

# Vérifier les installations
az --version
docker --version
```

## 🔧 Configuration Initiale

### 1. Se connecter à Azure

```bash
az login
```

### 2. Créer un Azure Container Registry (ACR)

```bash
# Créer ACR
az acr create --resource-group kdk-dev-rg --name kdkacr --sku Basic

# Se connecter à ACR
az acr login --name kdkacr
```

### 3. Modifier les fichiers de paramètres

Les fichiers de paramètres se trouvent dans `bicep/`:

- **parameters.dev.biceparam** - Environnement développement
- **parameters.staging.biceparam** - Environnement staging
- **parameters.prod.biceparam** - Environnement production

Modifiez selon vos besoins:

```biceparam
param resourcePrefix = 'kdk'  // Préfixe pour les ressources
param location = 'westeurope'  // Région Azure
param appServiceSku = 'Basic'  // Free, Basic, Standard, Premium
param sqlDatabaseEdition = 'Basic'  // Basic, Standard, Premium
param storageRedundancy = 'LRS'  // LRS, GRS, RAGRS, ZRS
param backendImageUri = 'kdkacr.azurecr.io/kidoikoiaki-backend:latest'
```

## 🎯 Déploiement

### Option 1: Utiliser le script de déploiement (Recommandé)

```bash
# Rendre le script exécutable
chmod +x bicep/deploy.sh

# Déployer en développement
./bicep/deploy.sh dev

# Déployer en staging
./bicep/deploy.sh staging westeurope

# Déployer en production
./bicep/deploy.sh prod
```

### Option 2: Déploiement manuel

#### Étape 1: Créer le groupe de ressources

```bash
az group create --name kdk-dev-rg --location westeurope
```

#### Étape 2: Construire les images Docker

```bash
# Build backend
docker build -f Dockerfile -t kdkacr.azurecr.io/kidoikoiaki-backend:latest .

# Build frontend (optionnel)
docker build -f Dockerfile.frontend -t kdkacr.azurecr.io/kidoikoiaki-frontend:latest .

# Push vers ACR
az acr login --name kdkacr
docker push kdkacr.azurecr.io/kidoikoiaki-backend:latest
docker push kdkacr.azurecr.io/kidoikoiaki-frontend:latest
```

#### Étape 3: Déployer avec Bicep

```bash
az deployment group create \
  --resource-group kdk-dev-rg \
  --template-file bicep/main.bicep \
  --parameters @bicep/parameters.dev.biceparam
```

## 📊 Structure des Templates Bicep

### main.bicep
- Template principal qui orchestre le déploiement
- Défini les paramètres globaux
- Module l'appel à `resources.bicep`

### resources.bicep
- Déploie toutes les ressources Azure:
  - **App Service Plan** - Plan d'hébergement
  - **Backend App Service** - Héberge l'API Express
  - **Frontend App Service** - Héberge la SPA React
  - **SQL Server & Database** - Base de données Azure SQL
  - **Storage Account** - Stockage des blobs (images)
  - **Key Vault** - Gestion des secrets
  - **Application Insights** - Monitoring et logs
  - **Rôles RBAC** - Accès aux ressources

### parameters.*.biceparam
- Fichiers de paramètres pour chaque environnement
- Permet une configuration différente par environnement

## 🌍 Ressources Déployées

### Par Environnement (dev, staging, prod):

| Ressource | dev | staging | prod |
|-----------|-----|---------|------|
| App Service Plan | Basic | Standard | Premium |
| SQL Edition | Basic | Standard | Premium |
| Storage | LRS | GRS | RAGRS |
| Always On | Non | Oui | Oui |

## 🔑 Variables d'Environnement

Après le déploiement, les variables suivantes sont configurées automatiquement dans l'App Service:

```bash
AZURE_SQL_SERVER=<server>.database.windows.net
AZURE_SQL_DATABASE=kdk-<env>-db
AZURE_STORAGE_ACCOUNT_NAME=kdk<env>storage
AZURE_STORAGE_ACCOUNT_KEY=<key>
APPLICATIONINSIGHTS_CONNECTION_STRING=<connection>
NODE_ENV=dev|staging|prod
PORT=8080
```

## 🔒 Sécurité

### Firewall SQL Server

Le template configure:
- ✓ Accès depuis Azure Services
- ✓ Accès depuis tous les IPs (développement uniquement)

**En production**, modifiez `resources.bicep` pour ajouter votre IP spécifique:

```bicep
resource sqlServerFirewallRule 'Microsoft.Sql/servers/firewallRules@2021-11-01' = {
  parent: sqlServer
  name: 'AllowMyIP'
  properties: {
    startIpAddress: 'YOUR_IP'
    endIpAddress: 'YOUR_IP'
  }
}
```

### HTTPS

- ✓ Tous les App Services forcent HTTPS
- ✓ TLS 1.2 minimum requis
- ✓ FTPS désactivé

### Identité Managée

- ✓ Backend App Service utilise une identité managée système
- ✓ Accès Key Vault, Storage, SQL sans clés

## 📊 Monitoring

Application Insights est automatiquement configuré. Accédez aux logs:

```bash
# Voir les logs de l'App Service
az webapp log tail --name kdk-dev-backend --resource-group kdk-dev-rg
```

## 🗑️ Nettoyage

Pour supprimer tous les ressources:

```bash
# Développement
az group delete --name kdk-dev-rg --yes

# Staging
az group delete --name kdk-staging-rg --yes

# Production
az group delete --name kdk-prod-rg --yes
```

## ⚠️ Points Importants

1. **ACR Registry**: Assurez-vous que `kdkacr.azurecr.io` existe ou modifiez le préfixe
2. **SQL Password**: Est généré automatiquement et stocké dans Key Vault
3. **Coûts**: Vérifiez les SKU (Basic = moins cher, Premium = plus performant)
4. **Région**: Modifiez `location` selon votre préférence (westeurope, eastus, etc.)
5. **Node Version**: Backend utilise Node 20-alpine, frontend Node 20-alpine

## 🆘 Dépannage

### Erreur: "Resource already exists"

```bash
# Vérifiez le nom des ressources (doit être unique globalement)
# Modifiez le paramètre resourcePrefix dans les fichiers .biceparam
```

### Erreur: "Invalid sku"

```bash
# Vérifiez les valeurs SKU disponibles:
az vm list-skus --location westeurope
```

### L'app ne démarre pas

```bash
# Vérifiez les logs
az webapp log tail --name kdk-dev-backend --resource-group kdk-dev-rg

# Vérifiez la connexion SQL
az sql server show --name <server> --resource-group kdk-dev-rg
```

## 📚 Ressources Supplémentaires

- [Documentation Bicep](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [Azure CLI Reference](https://learn.microsoft.com/en-us/cli/azure/)
- [App Service Documentation](https://learn.microsoft.com/en-us/azure/app-service/)
- [Azure SQL Database](https://learn.microsoft.com/en-us/azure/azure-sql/)

---

**Dernière mise à jour**: 5 février 2026
