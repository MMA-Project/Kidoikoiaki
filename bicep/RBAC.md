# Gestion RBAC et Sécurité - Kidoikoiaki

Ce guide explique le contrôle d'accès basé sur les rôles (RBAC) utilisé dans les templates Bicep.

## 📋 Rôles Configurés

### Backend App Service

Le backend a une **identité managée système** avec les rôles suivants:

#### 1. SQL Database - Contributor (optionnel)
```
Rôle: SQL DB Contributor
Scope: /subscriptions/{subscription}/resourceGroups/kdk-{env}-rg/providers/Microsoft.Sql/servers/{server}/databases/{database}
```

**Permissions**:
- Lire/Écrire les données
- Créer/modifier des tables
- Gérer les schémas

#### 2. Storage Account - Blob Data Contributor
```
Rôle: Storage Blob Data Contributor
Scope: /subscriptions/{subscription}/resourceGroups/kdk-{env}-rg/providers/Microsoft.Storage/storageAccounts/{storage}
```

**Permissions**:
- Lire/Écrire/Supprimer les blobs
- Lire les propriétés
- Lister les conteneurs

#### 3. Key Vault - Secrets User
```
Rôle: Key Vault Secrets User
Scope: /subscriptions/{subscription}/resourceGroups/kdk-{env}-rg/providers/Microsoft.KeyVault/vaults/{keyvault}
```

**Permissions**:
- Lire les secrets (mais pas les créer/modifier)
- Utiliser les certificats
- Accéder aux clés de chiffrement

## 🔐 Sécurité - Bonnes Pratiques

### ✅ À Faire

1. **Utiliser les identités managées**
   ```bicep
   identity: {
     type: 'SystemAssigned'  // ✓ Recommandé
   }
   ```

2. **Limiter les rôles au minimum nécessaire**
   - Ne pas utiliser "Owner" ou "Contributor" global
   - Utiliser des rôles spécifiques par ressource

3. **Protéger les secrets en Key Vault**
   - Ne jamais mettre les secrets dans le code
   - Utiliser des variables d'environnement

4. **Audit et monitoring**
   - Activer Application Insights
   - Examiner les logs Azure
   - Configurer les alertes

### ❌ À Éviter

1. **Partager des clés d'accès**
   ```bicep
   // ❌ Mauvais
   storageKey: storageAccount.listKeys().keys[0].value  // Exposé partout
   
   // ✓ Bon
   // Utiliser l'identité managée à la place
   ```

2. **Harcoder les secrets**
   ```typescript
   // ❌ Mauvais
   const password = "MySecurePassword123";
   
   // ✓ Bon
   const password = process.env.SQL_PASSWORD;
   ```

3. **Utiliser l'admin user pour tout**
   - Créer des users spécifiques par application
   - Limiter les permissions

## 🛠️ Configuration Manuelle des Rôles

### Avec le script

```bash
chmod +x bicep/setup-rbac.sh
./bicep/setup-rbac.sh dev
```

### Manuellement avec Azure CLI

#### 1. Créer une identité managée

```bash
# Pour une app existante
az webapp identity assign \
  --name kdk-dev-backend \
  --resource-group kdk-dev-rg \
  --role "Contributor"

# Récupérer l'ID principal
PRINCIPAL_ID=$(az webapp identity show \
  --name kdk-dev-backend \
  --resource-group kdk-dev-rg \
  --query "principalId" -o tsv)
```

#### 2. Assigner des rôles

```bash
# Rôle SQL Database
az role assignment create \
  --assignee-object-id "$PRINCIPAL_ID" \
  --role "SQL DB Contributor" \
  --scope "/subscriptions/{subscription-id}/resourceGroups/kdk-dev-rg/providers/Microsoft.Sql/servers/kdksqlserver/databases/kdk-dev-db"

# Rôle Storage
az role assignment create \
  --assignee-object-id "$PRINCIPAL_ID" \
  --role "Storage Blob Data Contributor" \
  --scope "/subscriptions/{subscription-id}/resourceGroups/kdk-dev-rg/providers/Microsoft.Storage/storageAccounts/kdkstorage"

# Rôle Key Vault
az role assignment create \
  --assignee-object-id "$PRINCIPAL_ID" \
  --role "Key Vault Secrets User" \
  --scope "/subscriptions/{subscription-id}/resourceGroups/kdk-dev-rg/providers/Microsoft.KeyVault/vaults/kdk-kv"
```

#### 3. Vérifier les rôles

```bash
az role assignment list \
  --assignee "$PRINCIPAL_ID" \
  --resource-group kdk-dev-rg
```

## 👥 Rôles Personnalisés

Pour les besoins avancés, créer un rôle personnalisé:

```json
{
  "Name": "Kidoikoiaki Backend Reader",
  "IsCustom": true,
  "Description": "Can read data for Kidoikoiaki backend",
  "Actions": [
    "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read",
    "Microsoft.Sql/servers/databases/read",
    "Microsoft.KeyVault/vaults/secrets/getSecret/action"
  ],
  "NotActions": [
    "Microsoft.Storage/storageAccounts/write"
  ]
}
```

```bash
az role definition create --role-definition @role.json
```

## 📊 Audit et Compliance

### Voir les assognations de rôles

```bash
# Pour une ressource
az role assignment list --scope "/subscriptions/{id}/resourceGroups/kdk-dev-rg"

# Pour un utilisateur/service principal
az role assignment list --assignee "$PRINCIPAL_ID"
```

### Activer le logging d'audit

```bash
# Dans Key Vault
az keyvault update \
  --name kdk-kv \
  --enable-purge-protection true \
  --enable-soft-delete true
```

### Alertes

```bash
# Via Azure Monitor
az monitor metrics alert create \
  --name "Failed-SQL-Connections" \
  --resource-group kdk-dev-rg \
  --scopes "/subscriptions/{id}/resourceGroups/kdk-dev-rg" \
  --condition "avg FailedLogins > 5" \
  --window-size "5m" \
  --evaluation-frequency "1m"
```

## 🔑 Gestion des Secrets

### Stocker dans Key Vault

```bash
# Créer un secret
az keyvault secret set \
  --vault-name kdk-kv \
  --name "db-password" \
  --value "SecurePassword123"

# Récupérer un secret
az keyvault secret show \
  --vault-name kdk-kv \
  --name "db-password" \
  --query "value" -o tsv
```

### Rotation des secrets

```bash
# Mettre à jour un secret
az keyvault secret set \
  --vault-name kdk-kv \
  --name "db-password" \
  --value "NewSecurePassword456"

# Historique
az keyvault secret list-versions \
  --vault-name kdk-kv \
  --name "db-password"
```

## 📚 Ressources

- [Azure RBAC Documentation](https://learn.microsoft.com/en-us/azure/role-based-access-control/)
- [Identités Managées](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/)
- [Key Vault Security](https://learn.microsoft.com/en-us/azure/key-vault/general/security-features)
- [SQL Database Authentication](https://learn.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-overview)

---

**Dernière mise à jour**: 5 février 2026
