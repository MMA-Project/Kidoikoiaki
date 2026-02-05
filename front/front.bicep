@description('Location for all resources')
param location string = resourceGroup().location

@description('Project name used for unique resource naming')
@minLength(3)
@maxLength(20)
param projectName string

@description('Node version for linuxFxVersion (ex: NODE|22-lts)')
param linuxFxVersion string = 'NODE|22-lts'

@description('Resource ID of an existing App Service Plan (serverfarm). If empty, create the plan in main.bicep and pass its id.')
param appServicePlanId string

@description('Enable HTTP/2')
param http20Enabled bool = true

@description('Whether the app requires client certificates')
param clientCertRequired bool = false

@description('Extra app settings to inject into the Web App')
param appSettings array = []

var frontAppName = '${projectName}-web-${uniqueString(resourceGroup().id)}'

resource frontApp 'Microsoft.Web/sites@2023-12-01' = {
  name: frontAppName
  location: location
  kind: 'app,linux'
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true

    // en général inutile pour un front; laissé paramétrable
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

output frontAppName string = frontApp.name
output frontUrl string = 'https://${frontApp.properties.defaultHostName}'