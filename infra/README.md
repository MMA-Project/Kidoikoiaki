# Infrastructure Deployment - Kidoikoiaki

Ce guide complet vous accompagne de la création des ressources Azure jusqu'au déploiement automatisé via GitHub Actions.

## 📋 Table des matières

1. [Ressources déployées](#ressources-déployées)
2. [Prérequis](#prérequis)
3. [Étape 1 : Configuration Azure](#étape-1--configuration-azure)
4. [Étape 2 : Déploiement de l'infrastructure](#étape-2--déploiement-de-linfrastructure)
5. [Étape 3 : Configuration post-déploiement](#étape-3--configuration-post-déploiement)
6. [Étape 4 : Configuration GitHub Actions](#étape-4--configuration-github-actions)
7. [Variables d'environnement](#variables-denvironnement)
8. [Surveillance](#surveillance)
9. [Dépannage](#dépannage)

## 🏗️ Ressources déployées

- **App Service Plan** (B1 Basic) - Hébergement partagé
- **Backend App Service** - API Node.js 22 + Express
- **Frontend App Service** - Application React + Vite
- **Azure Storage Account** - Stockage Blob pour les images/reçus
- **Azure SQL Server** - Serveur avec authentification Azure AD
- **Azure SQL Database** - Base de données (Basic tier, serverless)
- **Application Insights** - Monitoring et télémétrie
- **User Assigned Identity** - Identité managée pour OIDC GitHub

### Identités et permissions

- **Backend** : System Assigned Identity avec accès à SQL, Blob Storage
- **Frontend** : System Assigned Identity
- **OIDC Identity** : User Assigned Identity pour déploiement GitHub Actions

## ✅ Prérequis

- **Azure CLI** installé : [Installation](https://learn.microsoft.com/cli/azure/install-azure-cli)
- **Compte Azure** avec permissions de création de ressources
- **Compte GitHub** avec un repository pour le code
- **Node.js 18+** (pour tests locaux)

## 🚀 Étape 1 : Configuration Azure

### 1.1 Connexion à Azure

```bash
# Se connecter
az login

# Vérifier la subscription active
az account show --query "{name:name, id:id}"

# (Optionnel) Changer de subscription
az account set --subscription "VOTRE_SUBSCRIPTION_ID"
```

### 1.2 Créer le Resource Group

```bash
# Créer le resource group
az group create \
  --name my-rg \
  --location francecentral
```

### 1.3 Enregistrer les Resource Providers

**Important** : Certains providers doivent être enregistrés avant le déploiement.

```bash
# Enregistrer microsoft.operationalinsights (pour Application Insights)
az provider register --namespace microsoft.operationalinsights

# Vérifier le statut (doit être "Registered")
az provider show --namespace microsoft.operationalinsights --query "registrationState"

# Enregistrer les autres providers nécessaires
az provider register --namespace Microsoft.Web
az provider register --namespace Microsoft.Sql
az provider register --namespace Microsoft.Storage
az provider register --namespace Microsoft.ManagedIdentity
```

⏱️ **Note** : L'enregistrement peut prendre 2-5 minutes.

## 🔧 Étape 2 : Déploiement de l'infrastructure

### 2.1 Configurer les paramètres

Modifier le fichier `parameters.json` avec vos valeurs :

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "servers_ynov_sql_server_msimon_name": {
      "value": "votre-sql-server-name"
    },
    "sites_app_backend_kidoikoiaki_name": {
      "value": "app-backend-kidoikoiaki-votreNom"
    },
    "sites_app_frontend_kidoikoiaki_name": {
      "value": "app-frontend-kidoikoiaki-votreNom"
    },
    "storageAccounts_msimonblob_name": {
      "value": "votrenomblob"
    },
    "sqlAdminPassword": {
      "value": "VotreMotDePasse123!Sécurisé"
    }
  }
}
```

### 2.2 Déployer l'infrastructure

```bash
cd infra

# Déployer
az deployment group create \
  --resource-group my-rg \
  --template-file main.bicep \
  --parameters parameters.json

# ⏱️ Le déploiement prend environ 5-10 minutes
```

### 2.3 Vérifier le déploiement

```bash
# Lister les ressources créées
az resource list --resource-group my-rg --output table

# Obtenir les outputs (URLs des apps)
az deployment group show \
  --resource-group my-rg \
  --name main \
  --query properties.outputs
```

## ⚙️ Étape 3 : Configuration post-déploiement

### 3.1 Initialiser la base de données

```bash
# Récupérer le nom du serveur SQL
SQL_SERVER=$(az sql server list -g my-rg --query "[0].name" -o tsv)

# Se connecter et exécuter le script de seed
az sql db show-connection-string \
  --server $SQL_SERVER \
  --name ynov-msimon-sql \
  --client sqlcmd

# Ou depuis le backend local avec DefaultAzureCredential
cd ../backend
npm run seed
```

### 3.2 Configurer les CORS (si nécessaire)

Les CORS sont automatiquement configurés dans le template Bicep, mais vous pouvez les vérifier :

```bash
BACKEND_NAME="app-backend-kidoikoiaki-votreNom"

# Vérifier les CORS
az webapp cors show --name $BACKEND_NAME --resource-group my-rg

# Modifier si besoin
az webapp cors add \
  --name $BACKEND_NAME \
  --resource-group my-rg \
  --allowed-origins "https://app-frontend-kidoikoiaki-votreNom.azurewebsites.net"
```

### 3.3 Activer les logs

```bash
# Backend
az webapp log config \
  --name $BACKEND_NAME \
  --resource-group my-rg \
  --application-logging filesystem \
  --detailed-error-messages true \
  --failed-request-tracing true

# Frontend
az webapp log config \
  --name "app-frontend-kidoikoiaki-votreNom" \
  --resource-group my-rg \
  --application-logging filesystem
```

## 🔄 Étape 4 : Configuration GitHub Actions

### 4.1 Configurer OIDC avec GitHub (Recommandé)

**Avantages** : Pas de secrets à gérer, authentification sécurisée via identité managée.

```bash
# Récupérer l'Object ID de la User Assigned Identity
IDENTITY_ID=$(az identity show \
  --name oidc-msi-982b \
  --resource-group my-rg \
  --query principalId -o tsv)

# Configurer la federated identity pour GitHub
az identity federated-credential create \
  --name github-actions-federation \
  --identity-name oidc-msi-982b \
  --resource-group my-rg \
  --issuer https://token.actions.githubusercontent.com \
  --subject repo:VOTRE_GITHUB_ORG/VOTRE_REPO:ref:refs/heads/main \
  --audiences api://AzureADTokenExchange
```

### 4.2 Obtenir les Publish Profiles (Alternative)

Si vous préférez utiliser des publish profiles :

```bash
# Backend
az webapp deployment list-publishing-profiles \
  --name $BACKEND_NAME \
  --resource-group my-rg \
  --xml > backend-publish-profile.xml

# Frontend
az webapp deployment list-publishing-profiles \
  --name "app-frontend-kidoikoiaki-votreNom" \
  --resource-group my-rg \
  --xml > frontend-publish-profile.xml
```

### 4.3 Configurer les secrets GitHub

Allez sur votre repository GitHub : `Settings` → `Secrets and variables` → `Actions`

Ajoutez les secrets suivants :

#### Pour OIDC (recommandé) :
- `AZURE_CLIENT_ID` : Client ID de la User Assigned Identity
- `AZURE_TENANT_ID` : Votre Azure Tenant ID
- `AZURE_SUBSCRIPTION_ID` : Votre Subscription ID

```bash
# Obtenir les valeurs
az identity show --name oidc-msi-982b --resource-group my-rg --query clientId -o tsv
az account show --query tenantId -o tsv
az account show --query id -o tsv
```

#### Pour Publish Profile :
- `AZURE_WEBAPP_PUBLISH_PROFILE_BACKEND` : Contenu de `backend-publish-profile.xml`
- `AZURE_WEBAPP_PUBLISH_PROFILE_FRONTEND` : Contenu de `frontend-publish-profile.xml`

### 4.4 Vérifier les workflows

Les workflows GitHub Actions sont dans `.github/workflows/` :

- `main_app-backend-kidoikoiaki.yml` : Déploiement backend
- `main_app-frontend-kidoikoiaki.yml` : Déploiement frontend

### 4.5 Tester le déploiement

```bash
# Push sur main pour déclencher les workflows
git add .
git commit -m "Configure deployment"
git push origin main

# Vérifier l'exécution sur GitHub
# https://github.com/VOTRE_ORG/VOTRE_REPO/actions
```

## 📊 Variables d'environnement

### Backend (configurées automatiquement)
```bash
AZURE_SQL_SERVER=votre-server.database.windows.net
AZURE_SQL_DATABASE=ynov-msimon-sql
AZURE_STORAGE_ACCOUNT_NAME=votrenomblob
AZURE_STORAGE_CONTAINER_NAME=files
PORT=8080
NODE_ENV=production
```

### Frontend (configurées automatiquement)
```bash
VITE_API_URL=https://app-backend-kidoikoiaki-votreNom.azurewebsites.net
```

## 🔍 Surveillance

### Logs en temps réel

```bash
# Backend
az webapp log tail \
  --name app-backend-kidoikoiaki-votreNom \
  --resource-group my-rg

# Frontend
az webapp log tail \
  --name app-frontend-kidoikoiaki-votreNom \
  --resource-group my-rg
```

### Application Insights

```bash
# Obtenir l'URL d'Application Insights
az monitor app-insights component show \
  --app app-backend-kidoikoiaki-votreNom \
  --resource-group my-rg \
  --query "appId"
```

Accédez au portail Azure : `Application Insights` → `Logs` pour exécuter des requêtes KQL.

### Métriques utiles

```bash
# Santé de l'application
curl https://app-backend-kidoikoiaki-votreNom.azurewebsites.net/api/health

# Statistiques App Service
az webapp show \
  --name app-backend-kidoikoiaki-votreNom \
  --resource-group my-rg \
  --query "{state:state, defaultHostName:defaultHostName}"
```

## 🔧 Dépannage

### Erreur : "Failed to register resource provider"

```bash
# Enregistrer le provider manquant
az provider register --namespace microsoft.operationalinsights

# Attendre que le statut soit "Registered"
az provider show --namespace microsoft.operationalinsights --query "registrationState"
```

### Erreur : "MismatchingSubscriptionWithUrl"

Vérifiez que les IDs de subscription dans `main.bicep` correspondent à votre subscription active.

```bash
# Vérifier votre subscription
az account show --query id -o tsv

# Chercher les références hardcodées dans le template
grep -r "2ce35cbb-52a5-4a7c-962a-570844f51275" main.bicep
```

### Erreur SQL : "Login failed"

Assurez-vous que l'identité managée du backend a les permissions SQL :

```bash
# Ajouter l'identité comme SQL admin
az sql server ad-admin create \
  --resource-group my-rg \
  --server-name votre-sql-server \
  --display-name app-backend-kidoikoiaki \
  --object-id $(az webapp identity show --name app-backend-kidoikoiaki-votreNom --resource-group my-rg --query principalId -o tsv)
```

### Les déploiements GitHub Actions échouent

```bash
# Vérifier que les secrets sont bien configurés
# GitHub → Settings → Secrets and variables → Actions

# Tester manuellement le workflow
gh workflow run "Build and deploy Node.js app" --ref main
```

### L'application ne démarre pas

```bash
# Vérifier les logs de startup
az webapp log download \
  --name app-backend-kidoikoiaki-votreNom \
  --resource-group my-rg \
  --log-file logs.zip

# Redémarrer l'application
az webapp restart \
  --name app-backend-kidoikoiaki-votreNom \
  --resource-group my-rg
```

## 🧹 Nettoyage

### Supprimer toutes les ressources

```bash
# ⚠️ ATTENTION : Supprime tout !
az group delete --name my-rg --yes --no-wait

# Vérifier la suppression
az group exists --name my-rg
```

### Supprimer seulement certaines ressources

```bash
# Supprimer une App Service
az webapp delete \
  --name app-backend-kidoikoiaki-votreNom \
  --resource-group my-rg

# Supprimer la base de données
az sql db delete \
  --name ynov-msimon-sql \
  --server votre-sql-server \
  --resource-group my-rg
```

## 📚 Ressources utiles

- [Documentation Azure Bicep](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [App Service sur Linux](https://learn.microsoft.com/azure/app-service/overview)
- [Azure SQL Database](https://learn.microsoft.com/azure/azure-sql/database/)
- [GitHub Actions pour Azure](https://github.com/Azure/actions)
- [OIDC avec GitHub Actions](https://docs.github.com/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-azure)
