@description('Location for all resources')
param location string = resourceGroup().location

@description('Project name used for unique resource naming')
@minLength(3)
@maxLength(20)
param projectName string

@description('Node version for linuxFxVersion (ex: NODE|22-lts)')
param linuxFxVersion string = 'NODE|22-lts'
 
@description('Resource ID of an existing App Service Plan (serverfarm). If empty, you should create the plan in main.bicep and pass its id.')
param appServicePlanId string

@description('Whether the app requires client certificates')
param clientCertRequired bool = false

@description('Enable HTTP/2')
param http20Enabled bool = true

@description('Extra app settings to inject into the Web App')
param appSettings array = []

var appServiceName = '${projectName}-api-${uniqueString(resourceGroup().id)}'

resource appService 'Microsoft.Web/sites@2023-12-01' = {
  name: appServiceName
  location: location
  kind: 'app,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    clientCertEnabled: clientCertRequired
    clientCertMode: clientCertRequired ? 'Required' : 'Optional'
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      alwaysOn: false
      http20Enabled: http20Enabled
      minTlsVersion: '1.2'
      ftpsState: 'FtpsOnly'

      appSettings: union([
        {
          name: 'NODE_ENV'
          value: 'production'
        }
      ], appSettings)
    }
  }
}

output appServiceName string = appService.name
output appServiceUrl string = 'https://${appService.properties.defaultHostName}'
output appServicePrincipalId string = appService.identity.principalId