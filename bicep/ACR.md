# Configuration de l'Azure Container Registry (ACR)

Ce guide explique comment configurer Azure Container Registry pour Kidoikoiaki.

## 🔧 Configuration Initiale

### 1. Créer un ACR

```bash
# Créer le registre
az acr create \
  --resource-group kdk-dev-rg \
  --name kdkacr \
  --sku Basic

# Afficher les détails
az acr show --name kdkacr --query loginServer
```

### 2. Se connecter à ACR

```bash
# Avec Docker
az acr login --name kdkacr

# Vérifier la connexion
docker pull kdkacr.azurecr.io/hello-world:latest
```

### 3. Créer une clé d'accès (pour CI/CD)

```bash
# Activer l'admin user
az acr update -n kdkacr --admin-enabled true

# Récupérer les credentials
az acr credential show -n kdkacr
```

## 🐳 Push d'Images

### Manuellement

```bash
# Build local
docker build -f Dockerfile -t kdkacr.azurecr.io/kidoikoiaki-backend:latest .

# Push
docker push kdkacr.azurecr.io/kidoikoiaki-backend:latest

# Lister les images
az acr repository list --name kdkacr
```

### Via GitHub Actions (Automatique)

Les images sont automatiquement construites et poussées lors d'un push vers:
- `main` → production
- `develop` → staging
- autres branches → dev

## 📊 Gestion des Images

### Voir les images

```bash
# Lister tous les registres
az acr repository list --name kdkacr

# Lister les tags d'une image
az acr repository show-tags --name kdkacr --repository kidoikoiaki-backend
```

### Supprimer une image

```bash
# Supprimer un tag
az acr repository delete --name kdkacr --image kidoikoiaki-backend:old-tag

# Supprimer un repository entier
az acr repository delete --name kdkacr --repository kidoikoiaki-backend
```

### Nettoyer les images anciennes

```bash
# Supprimer les images non taggées
az acr run \
  --registry kdkacr \
  --cmd "acr purge --filter 'kidoikoiaki-backend:.*' --ago 30d --untagged" \
  /dev/null
```

## 🔐 Sécurité

### Webhook pour App Service

```bash
# Créer un webhook qui redéploie automatiquement App Service
az acr webhook create \
  --registry kdkacr \
  --name appservicewebhook \
  --actions push \
  --scope "kidoikoiaki-backend:*" \
  --uri https://kdk-dev-backend.azurewebsites.net/api/webhooks/acr
```

### Authentification

```bash
# Créer une clé d'accès pour l'App Service
az acr credential create \
  --registry kdkacr \
  --name kibapp \
  --role pull
```

## 💰 Coûts

- **Basic**: €5/mois (12 Go)
- **Standard**: €20/mois (100 Go)
- **Premium**: €60/mois (1 To)

Pour commencer, **Basic** est suffisant.

## 🆘 Dépannage

### Erreur: "denied: requesting access to the resource is denied"

```bash
# Vérifier la connexion
az acr login --name kdkacr

# Si cela ne marche pas, réauthentifier
az logout
az login
az acr login --name kdkacr
```

### Erreur: "name unknown"

```bash
# L'image n'existe pas, essayez de la builder/pousser:
docker build -f Dockerfile -t kdkacr.azurecr.io/kidoikoiaki-backend:latest .
docker push kdkacr.azurecr.io/kidoikoiaki-backend:latest
```

### L'App Service ne met pas à jour l'image

```bash
# Redémarrer l'App Service
az webapp restart --name kdk-dev-backend --resource-group kdk-dev-rg

# Ou forcer un redéploiement
az webapp config container set \
  --name kdk-dev-backend \
  --resource-group kdk-dev-rg \
  --docker-custom-image-name kdkacr.azurecr.io/kidoikoiaki-backend:latest \
  --docker-registry-server-url https://kdkacr.azurecr.io
```

## 📚 Ressources

- [Azure Container Registry Documentation](https://learn.microsoft.com/en-us/azure/container-registry/)
- [ACR Best Practices](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-best-practices)
