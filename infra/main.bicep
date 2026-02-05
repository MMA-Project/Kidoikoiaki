@description('Location for all resources')
param location string = resourceGroup().location

@description('Project name used for unique resource naming')
@minLength(3)
@maxLength(10)
param projectName string = 'kidoikoiaki'

@description('SQL Server administrator login')
@secure()
param sqlAdminLogin string

@description('SQL Server administrator password')
@secure()
param sqlAdminPassword string

var appServicePlanName = '${projectName}-plan'
var backendAppName = 'app-backend-${projectName}'
var frontendAppName = 'app-frontend-${projectName}'
var storageAccountName = '${projectName}storage${uniqueString(resourceGroup().id)}'
var sqlServerName = '${projectName}-sql-${uniqueString(resourceGroup().id)}'
var sqlDatabaseName = '${projectName}-db'
var appConfigName = '${projectName}-config-${uniqueString(resourceGroup().id)}'

// Azure Storage Account for Blob Storage
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
  }
}

// Blob Container
resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: '${storageAccount.name}/default/files'
  properties: {
    publicAccess: 'None'
  }
}

// Azure SQL Server
resource sqlServer 'Microsoft.Sql/servers@2023-05-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlAdminLogin
    administratorLoginPassword: sqlAdminPassword
    version: '12.0'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
  }
}

// Azure SQL Database
resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-05-01-preview' = {
  parent: sqlServer
  name: sqlDatabaseName
  location: location
  sku: {
    name: 'Basic'
    tier: 'Basic'
    capacity: 5
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 2147483648
  }
}

// SQL Server Firewall Rule - Allow Azure Services
resource sqlFirewallRule 'Microsoft.Sql/servers/firewallRules@2023-05-01-preview' = {
  parent: sqlServer
  name: 'AllowAzureServices'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

// Azure App Configuration
resource appConfiguration 'Microsoft.AppConfiguration/configurationStores@2023-03-01' = {
  name: appConfigName
  location: location
  sku: {
    name: 'free'
  }
  properties: {
    enablePurgeProtection: false
  }
}

// App Service Plan (Linux)
resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: appServicePlanName
  location: location
  kind: 'linux'
  sku: {
    name: 'B1'
    tier: 'Basic'
    capacity: 1
  }
  properties: {
    reserved: true
  }
}

// Backend App Service
resource backendAppService 'Microsoft.Web/sites@2023-12-01' = {
  name: backendAppName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'NODE|22-lts'
      alwaysOn: true
      http20Enabled: true
      minTlsVersion: '1.2'
      cors: {
        allowedOrigins: [
          'https://${frontendAppService.properties.defaultHostName}'
        ]
        supportCredentials: false
      }
      appSettings: [
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~22'
        }
        {
          name: 'NODE_ENV'
          value: 'production'
        }
        {
          name: 'PORT'
          value: '8080'
        }
        {
          name: 'AZURE_SQL_SERVER'
          value: sqlServer.properties.fullyQualifiedDomainName
        }
        {
          name: 'AZURE_SQL_DATABASE'
          value: sqlDatabaseName
        }
        {
          name: 'AZURE_STORAGE_ACCOUNT_NAME'
          value: storageAccount.name
        }
        {
          name: 'AZURE_STORAGE_CONTAINER_NAME'
          value: 'files'
        }
        {
          name: 'AZURE_APP_CONFIG_ENDPOINT'
          value: appConfiguration.properties.endpoint
        }
      ]
    }
    httpsOnly: true
  }
}

// Frontend App Service
resource frontendAppService 'Microsoft.Web/sites@2023-12-01' = {
  name: frontendAppName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'NODE|22-lts'
      alwaysOn: true
      http20Enabled: true
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~22'
        }
        {
          name: 'VITE_API_URL'
          value: 'https://${backendAppService.properties.defaultHostName}'
        }
      ]
    }
    httpsOnly: true
  }
}

// Role Assignments

// Backend App Service - Storage Blob Data Contributor
var storageBlobDataContributorRoleId = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
resource backendStorageRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, backendAppService.id, storageBlobDataContributorRoleId)
  scope: storageAccount
  properties: {
    principalId: backendAppService.identity.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataContributorRoleId)
    principalType: 'ServicePrincipal'
  }
}

// Backend App Service - App Configuration Data Reader
var appConfigDataReaderRoleId = '516239f1-63e1-4d78-a4de-a74fb236a071'
resource backendAppConfigRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(appConfiguration.id, backendAppService.id, appConfigDataReaderRoleId)
  scope: appConfiguration
  properties: {
    principalId: backendAppService.identity.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', appConfigDataReaderRoleId)
    principalType: 'ServicePrincipal'
  }
}

// Frontend App Service - App Configuration Data Reader
resource frontendAppConfigRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(appConfiguration.id, frontendAppService.id, appConfigDataReaderRoleId)
  scope: appConfiguration
  properties: {
    principalId: frontendAppService.identity.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', appConfigDataReaderRoleId)
    principalType: 'ServicePrincipal'
  }
}

output backendAppName string = backendAppService.name
output backendAppUrl string = 'https://${backendAppService.properties.defaultHostName}'
output frontendAppName string = frontendAppService.name
output frontendAppUrl string = 'https://${frontendAppService.properties.defaultHostName}'
output storageAccountName string = storageAccount.name
output sqlServerName string = sqlServer.name
output sqlDatabaseName string = sqlDatabase.name
output appConfigName string = appConfiguration.name
output appConfigEndpoint string = appConfiguration.properties.endpoint
output resourceGroupName string = resourceGroup().name
