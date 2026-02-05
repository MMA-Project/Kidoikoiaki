metadata description = 'Main Bicep template for Kidoikoiaki application deployment on Azure'

@minLength(1)
@maxLength(64)
@description('Name of the environment (dev, staging, prod)')
param environment string

@minLength(3)
@maxLength(24)
@description('Unique prefix for resource names')
param resourcePrefix string

@description('Azure region for resource deployment')
param location string = resourceGroup().location

@description('App Service Plan SKU (Free, Basic, Standard, Premium)')
param appServiceSku string = 'Basic'

@description('SQL Database edition (Basic, Standard, Premium)')
param sqlDatabaseEdition string = 'Basic'

@description('Storage Account redundancy (LRS, GRS, RAGRS, ZRS)')
param storageRedundancy string = 'LRS'

@description('Backend image URI from ACR or Docker Hub')
param backendImageUri string

@description('Frontend build artifacts container URI')
param frontendBuildUri string = ''

// Variables
var resourceNamePrefix = '${resourcePrefix}-${environment}'
var appServicePlanName = '${resourceNamePrefix}-app-plan'
var backendAppName = '${resourceNamePrefix}-backend'
var frontendAppName = '${resourceNamePrefix}-frontend'
var sqlServerName = '${resourcePrefix}sqlsrv${uniqueString(resourceGroup().id)}'
var sqlDatabaseName = '${resourceNamePrefix}-db'
var storageAccountName = '${replace(resourceNamePrefix, '-', '')}storage'
var containerRegistryName = '${replace(resourceNamePrefix, '-', '')}acr'
var keyVaultName = '${resourcePrefix}-kv-${uniqueString(resourceGroup().id)}'
var appInsightsName = '${resourceNamePrefix}-insights'

// Resource deployment
module appServiceResources 'resources.bicep' = {
  name: 'appServiceResources'
  params: {
    location: location
    appServicePlanName: appServicePlanName
    backendAppName: backendAppName
    frontendAppName: frontendAppName
    appServiceSku: appServiceSku
    sqlServerName: sqlServerName
    sqlDatabaseName: sqlDatabaseName
    sqlDatabaseEdition: sqlDatabaseEdition
    storageAccountName: storageAccountName
    storageRedundancy: storageRedundancy
    containerRegistryName: containerRegistryName
    keyVaultName: keyVaultName
    appInsightsName: appInsightsName
    backendImageUri: backendImageUri
    environment: environment
  }
}

output appServicePlanId string = appServiceResources.outputs.appServicePlanId
output backendAppUrl string = appServiceResources.outputs.backendAppUrl
output frontendAppUrl string = appServiceResources.outputs.frontendAppUrl
output sqlServerName string = appServiceResources.outputs.sqlServerName
output sqlDatabaseName string = appServiceResources.outputs.sqlDatabaseName
output storageAccountName string = appServiceResources.outputs.storageAccountName
output keyVaultName string = appServiceResources.outputs.keyVaultName
output appInsightsName string = appServiceResources.outputs.appInsightsName
