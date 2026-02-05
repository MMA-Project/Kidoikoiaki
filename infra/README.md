# Infrastructure Deployment

Ce dossier contient les fichiers Bicep pour déployer l'infrastructure Azure pour Kidoikoiaki.

## Ressources déployées

- **App Service Plan** (B1 Basic) - Plan d'hébergement partagé entre frontend et backend
- **Backend App Service** - Node.js 22 LTS avec Express
- **Frontend App Service** - Node.js 22 LTS avec Vite
- **Azure Storage Account** - Stockage Blob pour les images
- **Azure SQL Server** - Serveur SQL avec authentification Azure AD
- **Azure SQL Database** - Base de données (Basic tier)
- **Azure App Configuration** - Configuration centralisée

## Identités managées et permissions

Les App Services utilisent des identités managées (System Assigned) avec les permissions suivantes :

- **Backend** :
  - Storage Blob Data Contributor sur le Storage Account
  - App Configuration Data Reader sur App Configuration
  - Accès SQL via Azure AD

- **Frontend** :
  - App Configuration Data Reader sur App Configuration

## Déploiement

### Prérequis

- Azure CLI installé et connecté (`az login`)
- Bicep CLI installé
- Variables d'environnement configurées

### Commandes de déploiement

```bash
# Créer le resource group
az group create --name rg-kidoikoiaki --location westeurope

# Définir le mot de passe SQL admin
export SQL_ADMIN_PASSWORD='VotreMotDePasseSécurisé123!'

# Déployer l'infrastructure
az deployment group create \
  --resource-group rg-kidoikoiaki \
  --template-file main.bicep \
  --parameters main.bicepparam

# Ou avec des paramètres en ligne
az deployment group create \
  --resource-group rg-kidoikoiaki \
  --template-file main.bicep \
  --parameters projectName=kidoikoiaki \
               location=westeurope \
               sqlAdminLogin=sqladmin \
               sqlAdminPassword="$SQL_ADMIN_PASSWORD"
```

### Configuration post-déploiement

1. **Configurer l'accès SQL pour le backend** :
   ```bash
   # Ajouter l'identité managée du backend comme admin Azure AD
   az sql server ad-admin create \
     --resource-group rg-kidoikoiaki \
     --server-name <sql-server-name> \
     --display-name app-backend-kidoikoiaki \
     --object-id <backend-app-identity-principal-id>
   ```

2. **Initialiser la base de données** :
   - Exécuter les scripts de seed depuis le backend
   - Ou utiliser Azure Data Studio / SQL Server Management Studio

3. **Vérifier les CORS** :
   - Les CORS sont configurés automatiquement pour autoriser le frontend

## Variables d'environnement

### Backend
Les variables suivantes sont automatiquement configurées :
- `AZURE_SQL_SERVER`
- `AZURE_SQL_DATABASE`
- `AZURE_STORAGE_ACCOUNT_NAME`
- `AZURE_STORAGE_CONTAINER_NAME`
- `AZURE_APP_CONFIG_ENDPOINT`
- `PORT` (8080)
- `NODE_ENV` (production)

### Frontend
- `VITE_API_URL` - Pointe vers le backend

## Surveillance et debugging

```bash
# Voir les logs du backend
az webapp log tail --name app-backend-kidoikoiaki --resource-group rg-kidoikoiaki

# Voir les logs du frontend
az webapp log tail --name app-frontend-kidoikoiaki --resource-group rg-kidoikoiaki

# Obtenir les outputs du déploiement
az deployment group show \
  --resource-group rg-kidoikoiaki \
  --name main \
  --query properties.outputs
```

## Nettoyage

```bash
# Supprimer tout le resource group
az group delete --name rg-kidoikoiaki --yes
```
