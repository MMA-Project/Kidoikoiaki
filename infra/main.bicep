@secure()
param vulnerabilityAssessments_Default_storageContainerPath string
@secure()
param sqlAdminPassword string
param serverfarms_ASP_SQLGrp_ac58_name string
param sites_app_backend_kidoikoiaki_name string
param servers_ynov_sql_server_msimon_name string
param storageAccounts_msimonblob_name string
param sites_app_frontend_kidoikoiaki_name string
param components_app_backend_kidoikoiaki_name string
param components_app_frontend_kidoikoiaki_name string
param userAssignedIdentities_oidc_msi_982b_name string
param actionGroups_Application_Insights_Smart_Detection_name string

resource actionGroups_Application_Insights_Smart_Detection_name_resource 'microsoft.insights/actionGroups@2024-10-01-preview' = {
  name: actionGroups_Application_Insights_Smart_Detection_name
  location: 'Global'
  properties: {
    groupShortName: 'SmartDetect'
    enabled: true
    emailReceivers: []
    smsReceivers: []
    webhookReceivers: []
    eventHubReceivers: []
    itsmReceivers: []
    azureAppPushReceivers: []
    automationRunbookReceivers: []
    voiceReceivers: []
    logicAppReceivers: []
    azureFunctionReceivers: []
    armRoleReceivers: [
      {
        name: 'Monitoring Contributor'
        roleId: '749f88d5-cbae-40b8-bcfc-e573ddc772fa'
        useCommonAlertSchema: true
      }
      {
        name: 'Monitoring Reader'
        roleId: '43d0d8ad-25c7-4714-9337-8ba259a9fe05'
        useCommonAlertSchema: true
      }
    ]
  }
}

resource components_app_backend_kidoikoiaki_name_resource 'microsoft.insights/components@2020-02-02' = {
  name: components_app_backend_kidoikoiaki_name
  location: 'francecentral'
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Redfield'
    Request_Source: 'IbizaWebAppExtensionCreate'
    RetentionInDays: 90
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource components_app_frontend_kidoikoiaki_name_resource 'microsoft.insights/components@2020-02-02' = {
  name: components_app_frontend_kidoikoiaki_name
  location: 'francecentral'
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Redfield'
    Request_Source: 'IbizaWebAppExtensionCreate'
    RetentionInDays: 90
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource userAssignedIdentities_oidc_msi_982b_name_resource 'Microsoft.ManagedIdentity/userAssignedIdentities@2025-01-31-preview' = {
  name: userAssignedIdentities_oidc_msi_982b_name
  location: 'francecentral'
}

resource servers_ynov_sql_server_msimon_name_resource 'Microsoft.Sql/servers@2024-05-01-preview' = {
  name: servers_ynov_sql_server_msimon_name
  location: 'francecentral'
  kind: 'v12.0'
  properties: {
    administratorLogin: 'CloudSAc31d0a0d'
    administratorLoginPassword: sqlAdminPassword
    version: '12.0'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    administrators: {
      administratorType: 'ActiveDirectory'
      principalType: 'Group'
      login: 'Ynov/Nantes/Ynov Info/M2 DEVFSTACK/2025-2026'
      sid: '1153c4c4-47a2-4b80-877c-8749490e9a6e'
      tenantId: '38e72bba-3c22-4382-9323-ac1612931297'
      azureADOnlyAuthentication: false
    }
    restrictOutboundNetworkAccess: 'Disabled'
  }
}

resource storageAccounts_msimonblob_name_resource 'Microsoft.Storage/storageAccounts@2025-01-01' = {
  name: storageAccounts_msimonblob_name
  location: 'francecentral'
  sku: {
    name: 'Standard_RAGRS'
    tier: 'Standard'
  }
  kind: 'StorageV2'
  properties: {
    dnsEndpointType: 'Standard'
    defaultToOAuthAuthentication: false
    publicNetworkAccess: 'Enabled'
    allowCrossTenantReplication: false
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    largeFileSharesState: 'Enabled'
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      requireInfrastructureEncryption: false
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}

resource serverfarms_ASP_SQLGrp_ac58_name_resource 'Microsoft.Web/serverfarms@2024-11-01' = {
  name: serverfarms_ASP_SQLGrp_ac58_name
  location: 'France Central'
  sku: {
    name: 'B1'
    tier: 'Basic'
    size: 'B1'
    family: 'B'
    capacity: 1
  }
  kind: 'linux'
  properties: {
    perSiteScaling: false
    elasticScaleEnabled: false
    maximumElasticWorkerCount: 1
    isSpot: false
    freeOfferExpirationTime: '2026-08-05T10:25:16.1333333'
    reserved: true
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
    zoneRedundant: false
    asyncScalingEnabled: false
  }
}

resource components_app_backend_kidoikoiaki_name_degradationindependencyduration 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_app_backend_kidoikoiaki_name_resource
  name: 'degradationindependencyduration'
  location: 'francecentral'
  properties: {
    RuleDefinitions: {
      Name: 'degradationindependencyduration'
      DisplayName: 'Degradation in dependency duration'
      Description: 'Smart Detection rules notify you of performance anomaly issues.'
      HelpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: false
      SupportsEmailNotifications: true
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_app_frontend_kidoikoiaki_name_degradationindependencyduration 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_app_frontend_kidoikoiaki_name_resource
  name: 'degradationindependencyduration'
  location: 'francecentral'
  properties: {
    RuleDefinitions: {
      Name: 'degradationindependencyduration'
      DisplayName: 'Degradation in dependency duration'
      Description: 'Smart Detection rules notify you of performance anomaly issues.'
      HelpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: false
      SupportsEmailNotifications: true
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_app_backend_kidoikoiaki_name_degradationinserverresponsetime 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_app_backend_kidoikoiaki_name_resource
  name: 'degradationinserverresponsetime'
  location: 'francecentral'
  properties: {
    RuleDefinitions: {
      Name: 'degradationinserverresponsetime'
      DisplayName: 'Degradation in server response time'
      Description: 'Smart Detection rules notify you of performance anomaly issues.'
      HelpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: false
      SupportsEmailNotifications: true
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_app_frontend_kidoikoiaki_name_degradationinserverresponsetime 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_app_frontend_kidoikoiaki_name_resource
  name: 'degradationinserverresponsetime'
  location: 'francecentral'
  properties: {
    RuleDefinitions: {
      Name: 'degradationinserverresponsetime'
      DisplayName: 'Degradation in server response time'
      Description: 'Smart Detection rules notify you of performance anomaly issues.'
      HelpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: false
      SupportsEmailNotifications: true
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_app_backend_kidoikoiaki_name_digestMailConfiguration 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_app_backend_kidoikoiaki_name_resource
  name: 'digestMailConfiguration'
  location: 'francecentral'
  properties: {
    RuleDefinitions: {
      Name: 'digestMailConfiguration'
      DisplayName: 'Digest Mail Configuration'
      Description: 'This rule describes the digest mail preferences'
      HelpUrl: 'www.homail.com'
      IsHidden: true
      IsEnabledByDefault: true
      IsInPreview: false
      SupportsEmailNotifications: true
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_app_frontend_kidoikoiaki_name_digestMailConfiguration 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_app_frontend_kidoikoiaki_name_resource
  name: 'digestMailConfiguration'
  location: 'francecentral'
  properties: {
    RuleDefinitions: {
      Name: 'digestMailConfiguration'
      DisplayName: 'Digest Mail Configuration'
      Description: 'This rule describes the digest mail preferences'
      HelpUrl: 'www.homail.com'
      IsHidden: true
      IsEnabledByDefault: true
      IsInPreview: false
      SupportsEmailNotifications: true
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_app_backend_kidoikoiaki_name_extension_billingdatavolumedailyspikeextension 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_app_backend_kidoikoiaki_name_resource
  name: 'extension_billingdatavolumedailyspikeextension'
  location: 'francecentral'
  properties: {
    RuleDefinitions: {
      Name: 'extension_billingdatavolumedailyspikeextension'
      DisplayName: 'Abnormal rise in daily data volume (preview)'
      Description: 'This detection rule automatically analyzes the billing data generated by your application, and can warn you about an unusual increase in your application\'s billing costs'
      HelpUrl: 'https://github.com/Microsoft/ApplicationInsights-Home/tree/master/SmartDetection/billing-data-volume-daily-spike.md'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_app_frontend_kidoikoiaki_name_extension_billingdatavolumedailyspikeextension 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_app_frontend_kidoikoiaki_name_resource
  name: 'extension_billingdatavolumedailyspikeextension'
  location: 'francecentral'
  properties: {
    RuleDefinitions: {
      Name: 'extension_billingdatavolumedailyspikeextension'
      DisplayName: 'Abnormal rise in daily data volume (preview)'
      Description: 'This detection rule automatically analyzes the billing data generated by your application, and can warn you about an unusual increase in your application\'s billing costs'
      HelpUrl: 'https://github.com/Microsoft/ApplicationInsights-Home/tree/master/SmartDetection/billing-data-volume-daily-spike.md'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_app_backend_kidoikoiaki_name_extension_canaryextension 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_app_backend_kidoikoiaki_name_resource
  name: 'extension_canaryextension'
  location: 'francecentral'
  properties: {
    RuleDefinitions: {
      Name: 'extension_canaryextension'
      DisplayName: 'Canary extension'
      Description: 'Canary extension'
      HelpUrl: 'https://github.com/Microsoft/ApplicationInsights-Home/blob/master/SmartDetection/'
      IsHidden: true
      IsEnabledByDefault: true
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_app_frontend_kidoikoiaki_name_extension_canaryextension 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_app_frontend_kidoikoiaki_name_resource
  name: 'extension_canaryextension'
  location: 'francecentral'
  properties: {
    RuleDefinitions: {
      Name: 'extension_canaryextension'
      DisplayName: 'Canary extension'
      Description: 'Canary extension'
      HelpUrl: 'https://github.com/Microsoft/ApplicationInsights-Home/blob/master/SmartDetection/'
      IsHidden: true
      IsEnabledByDefault: true
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_app_backend_kidoikoiaki_name_extension_exceptionchangeextension 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_app_backend_kidoikoiaki_name_resource
  name: 'extension_exceptionchangeextension'
  location: 'francecentral'
  properties: {
    RuleDefinitions: {
      Name: 'extension_exceptionchangeextension'
      DisplayName: 'Abnormal rise in exception volume (preview)'
      Description: 'This detection rule automatically analyzes the exceptions thrown in your application, and can warn you about unusual patterns in your exception telemetry.'
      HelpUrl: 'https://github.com/Microsoft/ApplicationInsights-Home/blob/master/SmartDetection/abnormal-rise-in-exception-volume.md'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_app_frontend_kidoikoiaki_name_extension_exceptionchangeextension 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_app_frontend_kidoikoiaki_name_resource
  name: 'extension_exceptionchangeextension'
  location: 'francecentral'
  properties: {
    RuleDefinitions: {
      Name: 'extension_exceptionchangeextension'
      DisplayName: 'Abnormal rise in exception volume (preview)'
      Description: 'This detection rule automatically analyzes the exceptions thrown in your application, and can warn you about unusual patterns in your exception telemetry.'
      HelpUrl: 'https://github.com/Microsoft/ApplicationInsights-Home/blob/master/SmartDetection/abnormal-rise-in-exception-volume.md'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_app_backend_kidoikoiaki_name_extension_memoryleakextension 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_app_backend_kidoikoiaki_name_resource
  name: 'extension_memoryleakextension'
  location: 'francecentral'
  properties: {
    RuleDefinitions: {
      Name: 'extension_memoryleakextension'
      DisplayName: 'Potential memory leak detected (preview)'
      Description: 'This detection rule automatically analyzes the memory consumption of each process in your application, and can warn you about potential memory leaks or increased memory consumption.'
      HelpUrl: 'https://github.com/Microsoft/ApplicationInsights-Home/tree/master/SmartDetection/memory-leak.md'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_app_frontend_kidoikoiaki_name_extension_memoryleakextension 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_app_frontend_kidoikoiaki_name_resource
  name: 'extension_memoryleakextension'
  location: 'francecentral'
  properties: {
    RuleDefinitions: {
      Name: 'extension_memoryleakextension'
      DisplayName: 'Potential memory leak detected (preview)'
      Description: 'This detection rule automatically analyzes the memory consumption of each process in your application, and can warn you about potential memory leaks or increased memory consumption.'
      HelpUrl: 'https://github.com/Microsoft/ApplicationInsights-Home/tree/master/SmartDetection/memory-leak.md'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_app_backend_kidoikoiaki_name_extension_securityextensionspackage 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_app_backend_kidoikoiaki_name_resource
  name: 'extension_securityextensionspackage'
  location: 'francecentral'
  properties: {
    RuleDefinitions: {
      Name: 'extension_securityextensionspackage'
      DisplayName: 'Potential security issue detected (preview)'
      Description: 'This detection rule automatically analyzes the telemetry generated by your application and detects potential security issues.'
      HelpUrl: 'https://github.com/Microsoft/ApplicationInsights-Home/blob/master/SmartDetection/application-security-detection-pack.md'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_app_frontend_kidoikoiaki_name_extension_securityextensionspackage 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_app_frontend_kidoikoiaki_name_resource
  name: 'extension_securityextensionspackage'
  location: 'francecentral'
  properties: {
    RuleDefinitions: {
      Name: 'extension_securityextensionspackage'
      DisplayName: 'Potential security issue detected (preview)'
      Description: 'This detection rule automatically analyzes the telemetry generated by your application and detects potential security issues.'
      HelpUrl: 'https://github.com/Microsoft/ApplicationInsights-Home/blob/master/SmartDetection/application-security-detection-pack.md'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_app_backend_kidoikoiaki_name_extension_traceseveritydetector 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_app_backend_kidoikoiaki_name_resource
  name: 'extension_traceseveritydetector'
  location: 'francecentral'
  properties: {
    RuleDefinitions: {
      Name: 'extension_traceseveritydetector'
      DisplayName: 'Degradation in trace severity ratio (preview)'
      Description: 'This detection rule automatically analyzes the trace logs emitted from your application, and can warn you about unusual patterns in the severity of your trace telemetry.'
      HelpUrl: 'https://github.com/Microsoft/ApplicationInsights-Home/blob/master/SmartDetection/degradation-in-trace-severity-ratio.md'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_app_frontend_kidoikoiaki_name_extension_traceseveritydetector 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_app_frontend_kidoikoiaki_name_resource
  name: 'extension_traceseveritydetector'
  location: 'francecentral'
  properties: {
    RuleDefinitions: {
      Name: 'extension_traceseveritydetector'
      DisplayName: 'Degradation in trace severity ratio (preview)'
      Description: 'This detection rule automatically analyzes the trace logs emitted from your application, and can warn you about unusual patterns in the severity of your trace telemetry.'
      HelpUrl: 'https://github.com/Microsoft/ApplicationInsights-Home/blob/master/SmartDetection/degradation-in-trace-severity-ratio.md'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_app_backend_kidoikoiaki_name_longdependencyduration 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_app_backend_kidoikoiaki_name_resource
  name: 'longdependencyduration'
  location: 'francecentral'
  properties: {
    RuleDefinitions: {
      Name: 'longdependencyduration'
      DisplayName: 'Long dependency duration'
      Description: 'Smart Detection rules notify you of performance anomaly issues.'
      HelpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: false
      SupportsEmailNotifications: true
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_app_frontend_kidoikoiaki_name_longdependencyduration 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_app_frontend_kidoikoiaki_name_resource
  name: 'longdependencyduration'
  location: 'francecentral'
  properties: {
    RuleDefinitions: {
      Name: 'longdependencyduration'
      DisplayName: 'Long dependency duration'
      Description: 'Smart Detection rules notify you of performance anomaly issues.'
      HelpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: false
      SupportsEmailNotifications: true
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_app_backend_kidoikoiaki_name_migrationToAlertRulesCompleted 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_app_backend_kidoikoiaki_name_resource
  name: 'migrationToAlertRulesCompleted'
  location: 'francecentral'
  properties: {
    RuleDefinitions: {
      Name: 'migrationToAlertRulesCompleted'
      DisplayName: 'Migration To Alert Rules Completed'
      Description: 'A configuration that controls the migration state of Smart Detection to Smart Alerts'
      HelpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
      IsHidden: true
      IsEnabledByDefault: false
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: false
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_app_frontend_kidoikoiaki_name_migrationToAlertRulesCompleted 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_app_frontend_kidoikoiaki_name_resource
  name: 'migrationToAlertRulesCompleted'
  location: 'francecentral'
  properties: {
    RuleDefinitions: {
      Name: 'migrationToAlertRulesCompleted'
      DisplayName: 'Migration To Alert Rules Completed'
      Description: 'A configuration that controls the migration state of Smart Detection to Smart Alerts'
      HelpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
      IsHidden: true
      IsEnabledByDefault: false
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: false
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_app_backend_kidoikoiaki_name_slowpageloadtime 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_app_backend_kidoikoiaki_name_resource
  name: 'slowpageloadtime'
  location: 'francecentral'
  properties: {
    RuleDefinitions: {
      Name: 'slowpageloadtime'
      DisplayName: 'Slow page load time'
      Description: 'Smart Detection rules notify you of performance anomaly issues.'
      HelpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: false
      SupportsEmailNotifications: true
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_app_frontend_kidoikoiaki_name_slowpageloadtime 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_app_frontend_kidoikoiaki_name_resource
  name: 'slowpageloadtime'
  location: 'francecentral'
  properties: {
    RuleDefinitions: {
      Name: 'slowpageloadtime'
      DisplayName: 'Slow page load time'
      Description: 'Smart Detection rules notify you of performance anomaly issues.'
      HelpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: false
      SupportsEmailNotifications: true
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_app_backend_kidoikoiaki_name_slowserverresponsetime 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_app_backend_kidoikoiaki_name_resource
  name: 'slowserverresponsetime'
  location: 'francecentral'
  properties: {
    RuleDefinitions: {
      Name: 'slowserverresponsetime'
      DisplayName: 'Slow server response time'
      Description: 'Smart Detection rules notify you of performance anomaly issues.'
      HelpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: false
      SupportsEmailNotifications: true
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_app_frontend_kidoikoiaki_name_slowserverresponsetime 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_app_frontend_kidoikoiaki_name_resource
  name: 'slowserverresponsetime'
  location: 'francecentral'
  properties: {
    RuleDefinitions: {
      Name: 'slowserverresponsetime'
      DisplayName: 'Slow server response time'
      Description: 'Smart Detection rules notify you of performance anomaly issues.'
      HelpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: false
      SupportsEmailNotifications: true
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource userAssignedIdentities_oidc_msi_982b_name_oidc_credential_baf0 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2025-01-31-preview' = {
  parent: userAssignedIdentities_oidc_msi_982b_name_resource
  name: 'oidc-credential-baf0'
  properties: {
    issuer: 'https://token.actions.githubusercontent.com'
    subject: 'repo:MMA-Project/Kidoikoiaki:ref:refs/heads/main'
    audiences: [
      'api://AzureADTokenExchange'
    ]
  }
}

resource servers_ynov_sql_server_msimon_name_ActiveDirectory 'Microsoft.Sql/servers/administrators@2024-05-01-preview' = {
  parent: servers_ynov_sql_server_msimon_name_resource
  name: 'ActiveDirectory'
  properties: {
    administratorType: 'ActiveDirectory'
    login: 'Ynov/Nantes/Ynov Info/M2 DEVFSTACK/2025-2026'
    sid: '1153c4c4-47a2-4b80-877c-8749490e9a6e'
    tenantId: '38e72bba-3c22-4382-9323-ac1612931297'
  }
}

resource servers_ynov_sql_server_msimon_name_Default 'Microsoft.Sql/servers/advancedThreatProtectionSettings@2024-05-01-preview' = {
  parent: servers_ynov_sql_server_msimon_name_resource
  name: 'Default'
  properties: {
    state: 'Disabled'
  }
}

resource Microsoft_Sql_servers_auditingPolicies_servers_ynov_sql_server_msimon_name_Default 'Microsoft.Sql/servers/auditingPolicies@2014-04-01' = {
  parent: servers_ynov_sql_server_msimon_name_resource
  name: 'Default'
  location: 'France Central'
  properties: {
    auditingState: 'Disabled'
  }
}

resource Microsoft_Sql_servers_auditingSettings_servers_ynov_sql_server_msimon_name_Default 'Microsoft.Sql/servers/auditingSettings@2024-05-01-preview' = {
  parent: servers_ynov_sql_server_msimon_name_resource
  name: 'default'
  properties: {
    retentionDays: 0
    auditActionsAndGroups: []
    isStorageSecondaryKeyInUse: false
    isAzureMonitorTargetEnabled: false
    isManagedIdentityInUse: false
    state: 'Disabled'
    storageAccountSubscriptionId: '00000000-0000-0000-0000-000000000000'
  }
}

resource Microsoft_Sql_servers_azureADOnlyAuthentications_servers_ynov_sql_server_msimon_name_Default 'Microsoft.Sql/servers/azureADOnlyAuthentications@2024-05-01-preview' = {
  parent: servers_ynov_sql_server_msimon_name_resource
  name: 'Default'
  properties: {
    azureADOnlyAuthentication: false
  }
}

resource Microsoft_Sql_servers_connectionPolicies_servers_ynov_sql_server_msimon_name_default 'Microsoft.Sql/servers/connectionPolicies@2024-05-01-preview' = {
  parent: servers_ynov_sql_server_msimon_name_resource
  name: 'default'
  location: 'francecentral'
  properties: {
    connectionType: 'Default'
  }
}

resource servers_ynov_sql_server_msimon_name_ynov_msimon_sql 'Microsoft.Sql/servers/databases@2024-05-01-preview' = {
  parent: servers_ynov_sql_server_msimon_name_resource
  name: 'ynov-mnaud-sql'
  location: 'francecentral'
  sku: {
    name: 'GP_S_Gen5'
    tier: 'GeneralPurpose'
    family: 'Gen5'
    capacity: 1
  }
  kind: 'v12.0,user,vcore,serverless'
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 34359738368
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    zoneRedundant: false
    readScale: 'Disabled'
    autoPauseDelay: 60
    requestedBackupStorageRedundancy: 'Geo'
    minCapacity: json('0.5')
    maintenanceConfigurationId: '/subscriptions/6ba5dba5-7b0c-4088-9087-658f19d3126c/providers/Microsoft.Maintenance/publicMaintenanceConfigurations/SQL_Default'
    isLedgerOn: false
    availabilityZone: 'NoPreference'
  }
}

resource servers_ynov_sql_server_msimon_name_master_Default 'Microsoft.Sql/servers/databases/advancedThreatProtectionSettings@2024-05-01-preview' = {
  name: '${servers_ynov_sql_server_msimon_name}/master/Default'
  properties: {
    state: 'Disabled'
  }
  dependsOn: [
    servers_ynov_sql_server_msimon_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_auditingPolicies_servers_ynov_sql_server_msimon_name_master_Default 'Microsoft.Sql/servers/databases/auditingPolicies@2014-04-01' = {
  name: '${servers_ynov_sql_server_msimon_name}/master/Default'
  location: 'France Central'
  properties: {
    auditingState: 'Disabled'
  }
  dependsOn: [
    servers_ynov_sql_server_msimon_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_auditingSettings_servers_ynov_sql_server_msimon_name_master_Default 'Microsoft.Sql/servers/databases/auditingSettings@2024-05-01-preview' = {
  name: '${servers_ynov_sql_server_msimon_name}/master/Default'
  properties: {
    retentionDays: 0
    isAzureMonitorTargetEnabled: false
    state: 'Disabled'
    storageAccountSubscriptionId: '00000000-0000-0000-0000-000000000000'
  }
  dependsOn: [
    servers_ynov_sql_server_msimon_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_extendedAuditingSettings_servers_ynov_sql_server_msimon_name_master_Default 'Microsoft.Sql/servers/databases/extendedAuditingSettings@2024-05-01-preview' = {
  name: '${servers_ynov_sql_server_msimon_name}/master/Default'
  properties: {
    retentionDays: 0
    isAzureMonitorTargetEnabled: false
    state: 'Disabled'
    storageAccountSubscriptionId: '00000000-0000-0000-0000-000000000000'
  }
  dependsOn: [
    servers_ynov_sql_server_msimon_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_geoBackupPolicies_servers_ynov_sql_server_msimon_name_master_Default 'Microsoft.Sql/servers/databases/geoBackupPolicies@2024-05-01-preview' = {
  name: '${servers_ynov_sql_server_msimon_name}/master/Default'
  properties: {
    state: 'Disabled'
  }
  dependsOn: [
    servers_ynov_sql_server_msimon_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_securityAlertPolicies_servers_ynov_sql_server_msimon_name_master_Default 'Microsoft.Sql/servers/databases/securityAlertPolicies@2024-05-01-preview' = {
  name: '${servers_ynov_sql_server_msimon_name}/master/Default'
  properties: {
    state: 'Disabled'
    disabledAlerts: [
      ''
    ]
    emailAddresses: [
      ''
    ]
    emailAccountAdmins: false
    retentionDays: 0
  }
  dependsOn: [
    servers_ynov_sql_server_msimon_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_transparentDataEncryption_servers_ynov_sql_server_msimon_name_master_Current 'Microsoft.Sql/servers/databases/transparentDataEncryption@2024-05-01-preview' = {
  name: '${servers_ynov_sql_server_msimon_name}/master/Current'
  properties: {
    state: 'Disabled'
  }
  dependsOn: [
    servers_ynov_sql_server_msimon_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_vulnerabilityAssessments_servers_ynov_sql_server_msimon_name_master_Default 'Microsoft.Sql/servers/databases/vulnerabilityAssessments@2024-05-01-preview' = {
  name: '${servers_ynov_sql_server_msimon_name}/master/Default'
  properties: {
    recurringScans: {
      isEnabled: false
      emailSubscriptionAdmins: true
    }
  }
  dependsOn: [
    servers_ynov_sql_server_msimon_name_resource
  ]
}

resource Microsoft_Sql_servers_devOpsAuditingSettings_servers_ynov_sql_server_msimon_name_Default 'Microsoft.Sql/servers/devOpsAuditingSettings@2024-05-01-preview' = {
  parent: servers_ynov_sql_server_msimon_name_resource
  name: 'Default'
  properties: {
    isAzureMonitorTargetEnabled: false
    isManagedIdentityInUse: false
    state: 'Disabled'
    storageAccountSubscriptionId: '00000000-0000-0000-0000-000000000000'
  }
}

resource Microsoft_Sql_servers_extendedAuditingSettings_servers_ynov_sql_server_msimon_name_Default 'Microsoft.Sql/servers/extendedAuditingSettings@2024-05-01-preview' = {
  parent: servers_ynov_sql_server_msimon_name_resource
  name: 'default'
  properties: {
    retentionDays: 0
    auditActionsAndGroups: []
    isStorageSecondaryKeyInUse: false
    isAzureMonitorTargetEnabled: false
    isManagedIdentityInUse: false
    state: 'Disabled'
    storageAccountSubscriptionId: '00000000-0000-0000-0000-000000000000'
  }
}

resource servers_ynov_sql_server_msimon_name_AllowAllWindowsAzureIps 'Microsoft.Sql/servers/firewallRules@2024-05-01-preview' = {
  parent: servers_ynov_sql_server_msimon_name_resource
  name: 'AllowAllWindowsAzureIps'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource servers_ynov_sql_server_msimon_name_Client2 'Microsoft.Sql/servers/firewallRules@2024-05-01-preview' = {
  parent: servers_ynov_sql_server_msimon_name_resource
  name: 'Client2'
  properties: {
    startIpAddress: '77.135.189.178'
    endIpAddress: '77.135.189.178'
  }
}

resource servers_ynov_sql_server_msimon_name_ClientIPAddress_2026_2_4_10_31_10 'Microsoft.Sql/servers/firewallRules@2024-05-01-preview' = {
  parent: servers_ynov_sql_server_msimon_name_resource
  name: 'ClientIPAddress_2026-2-4_10-31-10'
  properties: {
    startIpAddress: '82.96.169.126'
    endIpAddress: '82.96.169.126'
  }
}

resource servers_ynov_sql_server_msimon_name_ClientIPAddress_2026_2_4_10_47_50 'Microsoft.Sql/servers/firewallRules@2024-05-01-preview' = {
  parent: servers_ynov_sql_server_msimon_name_resource
  name: 'ClientIPAddress_2026-2-4_10-47-50'
  properties: {
    startIpAddress: '77.135.189.178'
    endIpAddress: '77.135.189.178'
  }
}

resource servers_ynov_sql_server_msimon_name_ClientIPAddress_2026_2_5_17_5_50 'Microsoft.Sql/servers/firewallRules@2024-05-01-preview' = {
  parent: servers_ynov_sql_server_msimon_name_resource
  name: 'ClientIPAddress_2026-2-5_17-5-50'
  properties: {
    startIpAddress: '176.189.73.4'
    endIpAddress: '176.189.73.4'
  }
}

resource Microsoft_Sql_servers_securityAlertPolicies_servers_ynov_sql_server_msimon_name_Default 'Microsoft.Sql/servers/securityAlertPolicies@2024-05-01-preview' = {
  parent: servers_ynov_sql_server_msimon_name_resource
  name: 'Default'
  properties: {
    state: 'Disabled'
    disabledAlerts: [
      ''
    ]
    emailAddresses: [
      ''
    ]
    emailAccountAdmins: false
    retentionDays: 0
  }
}

resource Microsoft_Sql_servers_sqlVulnerabilityAssessments_servers_ynov_sql_server_msimon_name_Default 'Microsoft.Sql/servers/sqlVulnerabilityAssessments@2024-05-01-preview' = {
  parent: servers_ynov_sql_server_msimon_name_resource
  name: 'Default'
  properties: {
    state: 'Disabled'
  }
}

resource storageAccounts_msimonblob_name_default 'Microsoft.Storage/storageAccounts/blobServices@2025-01-01' = {
  parent: storageAccounts_msimonblob_name_resource
  name: 'default'
  sku: {
    name: 'Standard_RAGRS'
    tier: 'Standard'
  }
  properties: {
    containerDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      allowPermanentDelete: false
      enabled: true
      days: 7
    }
  }
}

resource Microsoft_Storage_storageAccounts_fileServices_storageAccounts_msimonblob_name_default 'Microsoft.Storage/storageAccounts/fileServices@2025-01-01' = {
  parent: storageAccounts_msimonblob_name_resource
  name: 'default'
  sku: {
    name: 'Standard_RAGRS'
    tier: 'Standard'
  }
  properties: {
    protocolSettings: {
      smb: {}
    }
    cors: {
      corsRules: []
    }
    shareDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}

resource Microsoft_Storage_storageAccounts_queueServices_storageAccounts_msimonblob_name_default 'Microsoft.Storage/storageAccounts/queueServices@2025-01-01' = {
  parent: storageAccounts_msimonblob_name_resource
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource Microsoft_Storage_storageAccounts_tableServices_storageAccounts_msimonblob_name_default 'Microsoft.Storage/storageAccounts/tableServices@2025-01-01' = {
  parent: storageAccounts_msimonblob_name_resource
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource sites_app_backend_kidoikoiaki_name_resource 'Microsoft.Web/sites@2024-11-01' = {
  name: sites_app_backend_kidoikoiaki_name
  location: 'France Central'
  tags: {
    'hidden-link: /app-insights-resource-id': components_app_backend_kidoikoiaki_name_resource.id
  }
  kind: 'app,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: '${sites_app_backend_kidoikoiaki_name}-b4ggc3c3bxdyhdgs.francecentral-01.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${sites_app_backend_kidoikoiaki_name}-b4ggc3c3bxdyhdgs.scm.francecentral-01.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: serverfarms_ASP_SQLGrp_ac58_name_resource.id
    reserved: true
    isXenon: false
    hyperV: false
    dnsConfiguration: {}
    outboundVnetRouting: {
      allTraffic: false
      applicationTraffic: false
      contentShareTraffic: false
      imagePullTraffic: false
      backupRestoreTraffic: false
    }
    siteConfig: {
      numberOfWorkers: 1
      linuxFxVersion: 'NODE|22-lts'
      acrUseManagedIdentityCreds: false
      alwaysOn: false
      http20Enabled: false
      functionAppScaleLimit: 0
      minimumElasticInstanceCount: 0
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: false
    clientAffinityProxyEnabled: false
    clientCertEnabled: false
    clientCertMode: 'Required'
    hostNamesDisabled: false
    ipMode: 'IPv4'
    customDomainVerificationId: '37F5A640C898CE164B8B96A7817753049B6281726EFBE0DC5B9446A42F1380ED'
    containerSize: 0
    dailyMemoryTimeQuota: 0
    httpsOnly: true
    endToEndEncryptionEnabled: false
    redundancyMode: 'None'
    publicNetworkAccess: 'Enabled'
    storageAccountRequired: false
    keyVaultReferenceIdentity: 'SystemAssigned'
    autoGeneratedDomainNameLabelScope: 'TenantReuse'
  }
}

resource sites_app_frontend_kidoikoiaki_name_resource 'Microsoft.Web/sites@2024-11-01' = {
  name: sites_app_frontend_kidoikoiaki_name
  location: 'France Central'
  tags: {
    'hidden-link: /app-insights-resource-id': components_app_frontend_kidoikoiaki_name_resource.id
  }
  kind: 'app,linux'
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: '${sites_app_frontend_kidoikoiaki_name}-byfxahaeb4b4gxge.francecentral-01.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${sites_app_frontend_kidoikoiaki_name}-byfxahaeb4b4gxge.scm.francecentral-01.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: serverfarms_ASP_SQLGrp_ac58_name_resource.id
    reserved: true
    isXenon: false
    hyperV: false
    dnsConfiguration: {}
    outboundVnetRouting: {
      allTraffic: false
      applicationTraffic: false
      contentShareTraffic: false
      imagePullTraffic: false
      backupRestoreTraffic: false
    }
    siteConfig: {
      numberOfWorkers: 1
      linuxFxVersion: 'NODE|22-lts'
      acrUseManagedIdentityCreds: false
      alwaysOn: false
      http20Enabled: false
      functionAppScaleLimit: 0
      minimumElasticInstanceCount: 0
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: false
    clientAffinityProxyEnabled: false
    clientCertEnabled: false
    clientCertMode: 'Required'
    hostNamesDisabled: false
    ipMode: 'IPv4'
    customDomainVerificationId: '37F5A640C898CE164B8B96A7817753049B6281726EFBE0DC5B9446A42F1380ED'
    containerSize: 0
    dailyMemoryTimeQuota: 0
    httpsOnly: true
    endToEndEncryptionEnabled: false
    redundancyMode: 'None'
    publicNetworkAccess: 'Enabled'
    storageAccountRequired: false
    keyVaultReferenceIdentity: 'SystemAssigned'
    autoGeneratedDomainNameLabelScope: 'TenantReuse'
  }
}

resource sites_app_backend_kidoikoiaki_name_ftp 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2024-11-01' = {
  parent: sites_app_backend_kidoikoiaki_name_resource
  name: 'ftp'
  location: 'France Central'
  tags: {
    'hidden-link: /app-insights-resource-id': components_app_backend_kidoikoiaki_name_resource.id
  }
  properties: {
    allow: true
  }
}

resource sites_app_frontend_kidoikoiaki_name_ftp 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2024-11-01' = {
  parent: sites_app_frontend_kidoikoiaki_name_resource
  name: 'ftp'
  location: 'France Central'
  tags: {
    'hidden-link: /app-insights-resource-id': components_app_frontend_kidoikoiaki_name_resource.id
  }
  properties: {
    allow: true
  }
}

resource sites_app_backend_kidoikoiaki_name_scm 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2024-11-01' = {
  parent: sites_app_backend_kidoikoiaki_name_resource
  name: 'scm'
  location: 'France Central'
  tags: {
    'hidden-link: /app-insights-resource-id': components_app_backend_kidoikoiaki_name_resource.id
  }
  properties: {
    allow: true
  }
}

resource sites_app_frontend_kidoikoiaki_name_scm 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2024-11-01' = {
  parent: sites_app_frontend_kidoikoiaki_name_resource
  name: 'scm'
  location: 'France Central'
  tags: {
    'hidden-link: /app-insights-resource-id': components_app_frontend_kidoikoiaki_name_resource.id
  }
  properties: {
    allow: true
  }
}

resource sites_app_backend_kidoikoiaki_name_web 'Microsoft.Web/sites/config@2024-11-01' = {
  parent: sites_app_backend_kidoikoiaki_name_resource
  name: 'web'
  location: 'France Central'
  tags: {
    'hidden-link: /app-insights-resource-id': components_app_backend_kidoikoiaki_name_resource.id
  }
  properties: {
    numberOfWorkers: 1
    defaultDocuments: [
      'Default.htm'
      'Default.html'
      'Default.asp'
      'index.htm'
      'index.html'
      'iisstart.htm'
      'default.aspx'
      'index.php'
      'hostingstart.html'
    ]
    netFrameworkVersion: 'v4.0'
    linuxFxVersion: 'NODE|22-lts'
    requestTracingEnabled: false
    remoteDebuggingEnabled: false
    httpLoggingEnabled: false
    acrUseManagedIdentityCreds: false
    logsDirectorySizeLimit: 35
    detailedErrorLoggingEnabled: false
    publishingUsername: '$app-backend-kidoikoiaki'
    scmType: 'GitHubAction'
    use32BitWorkerProcess: true
    webSocketsEnabled: false
    alwaysOn: false
    appCommandLine: 'node dist/index.js'
    managedPipelineMode: 'Integrated'
    virtualApplications: [
      {
        virtualPath: '/'
        physicalPath: 'site\\wwwroot'
        preloadEnabled: false
      }
    ]
    loadBalancing: 'LeastRequests'
    experiments: {
      rampUpRules: []
    }
    autoHealEnabled: false
    vnetRouteAllEnabled: false
    vnetPrivatePortsCount: 0
    publicNetworkAccess: 'Enabled'
    cors: {
      allowedOrigins: [
        'https://app-frontend-kidoikoiaki-byfxahaeb4b4gxge.francecentral-01.azurewebsites.net'
      ]
      supportCredentials: true
    }
    localMySqlEnabled: false
    managedServiceIdentityId: 3786
    ipSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictionsUseMain: false
    http20Enabled: false
    minTlsVersion: '1.2'
    scmMinTlsVersion: '1.2'
    ftpsState: 'FtpsOnly'
    preWarmedInstanceCount: 0
    elasticWebAppScaleLimit: 0
    functionsRuntimeScaleMonitoringEnabled: false
    minimumElasticInstanceCount: 0
    azureStorageAccounts: {}
    http20ProxyFlag: 0
  }
}

resource sites_app_frontend_kidoikoiaki_name_web 'Microsoft.Web/sites/config@2024-11-01' = {
  parent: sites_app_frontend_kidoikoiaki_name_resource
  name: 'web'
  location: 'France Central'
  tags: {
    'hidden-link: /app-insights-resource-id': components_app_frontend_kidoikoiaki_name_resource.id
  }
  properties: {
    numberOfWorkers: 1
    defaultDocuments: [
      'Default.htm'
      'Default.html'
      'Default.asp'
      'index.htm'
      'index.html'
      'iisstart.htm'
      'default.aspx'
      'index.php'
      'hostingstart.html'
    ]
    netFrameworkVersion: 'v4.0'
    linuxFxVersion: 'NODE|22-lts'
    requestTracingEnabled: false
    remoteDebuggingEnabled: false
    httpLoggingEnabled: false
    acrUseManagedIdentityCreds: false
    logsDirectorySizeLimit: 35
    detailedErrorLoggingEnabled: false
    publishingUsername: '$app-frontend-kidoikoiaki'
    scmType: 'None'
    use32BitWorkerProcess: true
    webSocketsEnabled: false
    alwaysOn: false
    appCommandLine: 'pm2 serve /home/site/wwwroot/dist --no-daemon --spa'
    managedPipelineMode: 'Integrated'
    virtualApplications: [
      {
        virtualPath: '/'
        physicalPath: 'site\\wwwroot'
        preloadEnabled: false
      }
    ]
    loadBalancing: 'LeastRequests'
    experiments: {
      rampUpRules: []
    }
    autoHealEnabled: false
    vnetRouteAllEnabled: false
    vnetPrivatePortsCount: 0
    publicNetworkAccess: 'Enabled'
    localMySqlEnabled: false
    ipSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictionsUseMain: false
    http20Enabled: false
    minTlsVersion: '1.2'
    scmMinTlsVersion: '1.2'
    ftpsState: 'FtpsOnly'
    preWarmedInstanceCount: 0
    elasticWebAppScaleLimit: 0
    functionsRuntimeScaleMonitoringEnabled: false
    minimumElasticInstanceCount: 0
    azureStorageAccounts: {}
    http20ProxyFlag: 0
  }
}

resource sites_app_frontend_kidoikoiaki_name_0b8b81e3_b8a8_411d_a658_a5650b759724 'Microsoft.Web/sites/deployments@2024-11-01' = {
  parent: sites_app_frontend_kidoikoiaki_name_resource
  name: '0b8b81e3-b8a8-411d-a658-a5650b759724'
  location: 'France Central'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'N/A'
    deployer: 'GITHUB_ZIP_DEPLOY'
    message: '{"type":"deployment","sha":"ee0df35e01527a79932ac6b5e494386437b6b6dd","repoName":"MMA-Project/Kidoikoiaki","actor":"helldeal","slotName":"production","commitMessage":"test"}'
    start_time: '2026-02-05T13:36:17.0595213Z'
    end_time: '2026-02-05T13:36:26.6058294Z'
    active: false
  }
}

resource sites_app_frontend_kidoikoiaki_name_1c8303c6_95f5_4400_a841_2c653089a1e0 'Microsoft.Web/sites/deployments@2024-11-01' = {
  parent: sites_app_frontend_kidoikoiaki_name_resource
  name: '1c8303c6-95f5-4400-a841-2c653089a1e0'
  location: 'France Central'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'N/A'
    deployer: 'GITHUB_ZIP_DEPLOY'
    message: '{"type":"deployment","sha":"9c31583764b6d1ae30c9c92464171da64cbe8a5e","repoName":"MMA-Project/Kidoikoiaki","actor":"helldeal","slotName":"production","commitMessage":"je suis nul"}'
    start_time: '2026-02-05T14:51:38.5542858Z'
    end_time: '2026-02-05T14:53:43.8440951Z'
    active: false
  }
}

resource sites_app_frontend_kidoikoiaki_name_1fd7084c_cd68_49ce_9ae8_68fa908e367b 'Microsoft.Web/sites/deployments@2024-11-01' = {
  parent: sites_app_frontend_kidoikoiaki_name_resource
  name: '1fd7084c-cd68-49ce-9ae8-68fa908e367b'
  location: 'France Central'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'N/A'
    deployer: 'GITHUB_ZIP_DEPLOY'
    message: '{"type":"deployment","sha":"3d34a5eb3452a704d95c424956c2a69c50b3150c","repoName":"MMA-Project/Kidoikoiaki","actor":"helldeal","slotName":"production","commitMessage":"delete env"}'
    start_time: '2026-02-05T22:41:28.5531019Z'
    end_time: '2026-02-05T22:43:17.0180131Z'
    active: false
  }
}

resource sites_app_frontend_kidoikoiaki_name_2451f1ce_0f10_4f16_90a1_0091e33438b6 'Microsoft.Web/sites/deployments@2024-11-01' = {
  parent: sites_app_frontend_kidoikoiaki_name_resource
  name: '2451f1ce-0f10-4f16-90a1-0091e33438b6'
  location: 'France Central'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'N/A'
    deployer: 'GITHUB_ZIP_DEPLOY'
    message: '{"type":"deployment","sha":"8e259a63b20c6fe5d33024c45dc715eeb2f97085","repoName":"MMA-Project/Kidoikoiaki","actor":"helldeal","slotName":"production","commitMessage":"VITE_API_URL on build"}'
    start_time: '2026-02-05T23:00:03.8030963Z'
    end_time: '2026-02-05T23:01:36.1574567Z'
    active: true
  }
}

resource sites_app_frontend_kidoikoiaki_name_305d780c_498c_4bdd_a5f0_fb7344961d7b 'Microsoft.Web/sites/deployments@2024-11-01' = {
  parent: sites_app_frontend_kidoikoiaki_name_resource
  name: '305d780c-498c-4bdd-a5f0-fb7344961d7b'
  location: 'France Central'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'N/A'
    deployer: 'GITHUB_ZIP_DEPLOY'
    message: '{"type":"deployment","sha":"427956c261714db29d7b44b9bf3940e665757a0f","repoName":"MMA-Project/Kidoikoiaki","actor":"helldeal","slotName":"production","commitMessage":"try with package only"}'
    start_time: '2026-02-05T14:21:52.2326233Z'
    end_time: '2026-02-05T14:26:21.2916325Z'
    active: false
  }
}

resource sites_app_backend_kidoikoiaki_name_46b2d8c9_d19c_4d6f_aada_3afcce1e67aa 'Microsoft.Web/sites/deployments@2024-11-01' = {
  parent: sites_app_backend_kidoikoiaki_name_resource
  name: '46b2d8c9-d19c-4d6f-aada-3afcce1e67aa'
  location: 'France Central'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'N/A'
    deployer: 'GITHUB_ZIP_DEPLOY'
    message: '{"type":"deployment","sha":"c84e05779d565e5966575e89b1960fc7d4f65103","repoName":"MMA-Project/Kidoikoiaki","actor":"helldeal","slotName":"production","commitMessage":"main bicep"}'
    start_time: '2026-02-05T13:28:26.3501522Z'
    end_time: '2026-02-05T13:29:00.3557784Z'
    active: false
  }
}

resource sites_app_backend_kidoikoiaki_name_5661e026_7e66_44f2_839e_eb85907e91f7 'Microsoft.Web/sites/deployments@2024-11-01' = {
  parent: sites_app_backend_kidoikoiaki_name_resource
  name: '5661e026-7e66-44f2-839e-eb85907e91f7'
  location: 'France Central'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'N/A'
    deployer: 'GITHUB_ZIP_DEPLOY'
    message: '{"type":"deployment","sha":"8e259a63b20c6fe5d33024c45dc715eeb2f97085","repoName":"MMA-Project/Kidoikoiaki","actor":"helldeal","slotName":"production","commitMessage":"VITE_API_URL on build"}'
    start_time: '2026-02-05T23:00:54.3673725Z'
    end_time: '2026-02-05T23:02:00.198823Z'
    active: true
  }
}

resource sites_app_backend_kidoikoiaki_name_61c55075_dbe2_4de2_a4e4_22a74d0caaa2 'Microsoft.Web/sites/deployments@2024-11-01' = {
  parent: sites_app_backend_kidoikoiaki_name_resource
  name: '61c55075-dbe2-4de2-a4e4-22a74d0caaa2'
  location: 'France Central'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'N/A'
    deployer: 'GITHUB_ZIP_DEPLOY'
    message: '{"type":"deployment","sha":"9c31583764b6d1ae30c9c92464171da64cbe8a5e","repoName":"MMA-Project/Kidoikoiaki","actor":"helldeal","slotName":"production","commitMessage":"je suis nul"}'
    start_time: '2026-02-05T14:52:58.4527705Z'
    end_time: '2026-02-05T14:54:47.5621825Z'
    active: false
  }
}

resource sites_app_backend_kidoikoiaki_name_6700f71e_c252_4115_a2b9_6e68e1a4c459 'Microsoft.Web/sites/deployments@2024-11-01' = {
  parent: sites_app_backend_kidoikoiaki_name_resource
  name: '6700f71e-c252-4115-a2b9-6e68e1a4c459'
  location: 'France Central'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'N/A'
    deployer: 'GITHUB_ZIP_DEPLOY'
    message: '{"type":"deployment","sha":"8e259a63b20c6fe5d33024c45dc715eeb2f97085","repoName":"MMA-Project/Kidoikoiaki","actor":"helldeal","slotName":"production","commitMessage":"VITE_API_URL on build"}'
    start_time: '2026-02-05T22:51:51.6023543Z'
    end_time: '2026-02-05T22:54:30.225813Z'
    active: false
  }
}

resource sites_app_backend_kidoikoiaki_name_6fbb2e94_547a_400e_b483_57a09e8bb6df 'Microsoft.Web/sites/deployments@2024-11-01' = {
  parent: sites_app_backend_kidoikoiaki_name_resource
  name: '6fbb2e94-547a-400e-b483-57a09e8bb6df'
  location: 'France Central'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'N/A'
    deployer: 'GITHUB_ZIP_DEPLOY'
    message: '{"type":"deployment","sha":"f054651a189f5bb09b34ca5726a08a11e3d3bbe0","repoName":"MMA-Project/Kidoikoiaki","actor":"helldeal","slotName":"production","commitMessage":"DefaultAzureCredential"}'
    start_time: '2026-02-05T15:50:23.1926885Z'
    end_time: '2026-02-05T15:53:24.4031496Z'
    active: false
  }
}

resource sites_app_backend_kidoikoiaki_name_799a7262_6698_4eeb_a909_809c5124c6d2 'Microsoft.Web/sites/deployments@2024-11-01' = {
  parent: sites_app_backend_kidoikoiaki_name_resource
  name: '799a7262-6698-4eeb-a909-809c5124c6d2'
  location: 'France Central'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'N/A'
    deployer: 'GITHUB_ZIP_DEPLOY'
    message: '{"type":"deployment","sha":"3d34a5eb3452a704d95c424956c2a69c50b3150c","repoName":"MMA-Project/Kidoikoiaki","actor":"helldeal","slotName":"production","commitMessage":"delete env"}'
    start_time: '2026-02-05T22:41:36.4070561Z'
    end_time: '2026-02-05T22:43:32.1147974Z'
    active: false
  }
}

resource sites_app_frontend_kidoikoiaki_name_7dd49e25_1de8_4b1c_88d6_7679b2f4409b 'Microsoft.Web/sites/deployments@2024-11-01' = {
  parent: sites_app_frontend_kidoikoiaki_name_resource
  name: '7dd49e25-1de8-4b1c-88d6-7679b2f4409b'
  location: 'France Central'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'N/A'
    deployer: 'GITHUB_ZIP_DEPLOY'
    message: '{"type":"deployment","sha":"d8fdb12915d8acaed490719f0f2d95773c76bd47","repoName":"MMA-Project/Kidoikoiaki","actor":"helldeal","slotName":"production","commitMessage":"read and write perm"}'
    start_time: '2026-02-05T14:45:14.1543634Z'
    end_time: '2026-02-05T14:46:13.9230534Z'
    active: false
  }
}

resource sites_app_frontend_kidoikoiaki_name_a993d6d7_8e03_40e4_ba01_6fb984edb7b2 'Microsoft.Web/sites/deployments@2024-11-01' = {
  parent: sites_app_frontend_kidoikoiaki_name_resource
  name: 'a993d6d7-8e03-40e4-ba01-6fb984edb7b2'
  location: 'France Central'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'N/A'
    deployer: 'GITHUB_ZIP_DEPLOY'
    message: '{"type":"deployment","sha":"3a35b4308aa023a707848501f853b27024ac33eb","repoName":"MMA-Project/Kidoikoiaki","actor":"helldeal","slotName":"production","commitMessage":"test with az login instead"}'
    start_time: '2026-02-05T14:41:26.1802753Z'
    end_time: '2026-02-05T14:42:40.6211576Z'
    active: false
  }
}

resource sites_app_frontend_kidoikoiaki_name_afd2fd6c_d38c_4cf2_8ac6_05d5a72e3d6c 'Microsoft.Web/sites/deployments@2024-11-01' = {
  parent: sites_app_frontend_kidoikoiaki_name_resource
  name: 'afd2fd6c-d38c-4cf2-8ac6-05d5a72e3d6c'
  location: 'France Central'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'N/A'
    deployer: 'GITHUB_ZIP_DEPLOY'
    message: '{"type":"deployment","sha":"8e259a63b20c6fe5d33024c45dc715eeb2f97085","repoName":"MMA-Project/Kidoikoiaki","actor":"helldeal","slotName":"production","commitMessage":"VITE_API_URL on build"}'
    start_time: '2026-02-05T22:50:30.064871Z'
    end_time: '2026-02-05T22:53:42.6961862Z'
    active: false
  }
}

resource sites_app_backend_kidoikoiaki_name_b5442b98_b04e_413e_91e4_c0db55d2a9e2 'Microsoft.Web/sites/deployments@2024-11-01' = {
  parent: sites_app_backend_kidoikoiaki_name_resource
  name: 'b5442b98-b04e-413e-91e4-c0db55d2a9e2'
  location: 'France Central'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'N/A'
    deployer: 'GITHUB_ZIP_DEPLOY'
    message: '{"type":"deployment","sha":"ee0df35e01527a79932ac6b5e494386437b6b6dd","repoName":"MMA-Project/Kidoikoiaki","actor":"helldeal","slotName":"production","commitMessage":"test"}'
    start_time: '2026-02-05T13:35:55.2546001Z'
    end_time: '2026-02-05T13:38:22.9590335Z'
    active: false
  }
}

resource sites_app_frontend_kidoikoiaki_name_c55f0c1c_00fb_4f20_bf36_a2f1a5162009 'Microsoft.Web/sites/deployments@2024-11-01' = {
  parent: sites_app_frontend_kidoikoiaki_name_resource
  name: 'c55f0c1c-00fb-4f20-bf36-a2f1a5162009'
  location: 'France Central'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'N/A'
    deployer: 'GITHUB_ZIP_DEPLOY'
    message: '{"type":"deployment","sha":"f054651a189f5bb09b34ca5726a08a11e3d3bbe0","repoName":"MMA-Project/Kidoikoiaki","actor":"helldeal","slotName":"production","commitMessage":"DefaultAzureCredential"}'
    start_time: '2026-02-05T15:49:37.1157752Z'
    end_time: '2026-02-05T15:51:58.2993973Z'
    active: false
  }
}

resource sites_app_backend_kidoikoiaki_name_ca6bf6d3_c1b8_498b_a8ce_2b4c0d37c231 'Microsoft.Web/sites/deployments@2024-11-01' = {
  parent: sites_app_backend_kidoikoiaki_name_resource
  name: 'ca6bf6d3-c1b8-498b-a8ce-2b4c0d37c231'
  location: 'France Central'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'N/A'
    deployer: 'GITHUB_ZIP_DEPLOY'
    message: '{"type":"deployment","sha":"d8fdb12915d8acaed490719f0f2d95773c76bd47","repoName":"MMA-Project/Kidoikoiaki","actor":"helldeal","slotName":"production","commitMessage":"read and write perm"}'
    start_time: '2026-02-05T14:45:08.0685113Z'
    end_time: '2026-02-05T14:45:17.2407512Z'
    active: false
  }
}

resource sites_app_backend_kidoikoiaki_name_dc2d5a2f_86d3_4c01_ba9d_d68e0f21b43e 'Microsoft.Web/sites/deployments@2024-11-01' = {
  parent: sites_app_backend_kidoikoiaki_name_resource
  name: 'dc2d5a2f-86d3-4c01-ba9d-d68e0f21b43e'
  location: 'France Central'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'N/A'
    deployer: 'GITHUB_ZIP_DEPLOY'
    message: '{"type":"deployment","sha":"427956c261714db29d7b44b9bf3940e665757a0f","repoName":"MMA-Project/Kidoikoiaki","actor":"helldeal","slotName":"production","commitMessage":"try with package only"}'
    start_time: '2026-02-05T14:18:59.6895474Z'
    end_time: '2026-02-05T14:19:36.0826113Z'
    active: false
  }
}

resource sites_app_frontend_kidoikoiaki_name_e4963ca9_94aa_4bd7_953c_3b6c44684f84 'Microsoft.Web/sites/deployments@2024-11-01' = {
  parent: sites_app_frontend_kidoikoiaki_name_resource
  name: 'e4963ca9-94aa-4bd7-953c-3b6c44684f84'
  location: 'France Central'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'N/A'
    deployer: 'GITHUB_ZIP_DEPLOY'
    message: '{"type":"deployment","sha":"d3fd997b06a7af907e758d57e4ba8feec6be4f82","repoName":"MMA-Project/Kidoikoiaki","actor":"helldeal","slotName":"production","commitMessage":"TEST"}'
    start_time: '2026-02-05T14:07:59.0880376Z'
    end_time: '2026-02-05T14:08:07.1768855Z'
    active: false
  }
}

resource sites_app_backend_kidoikoiaki_name_f63a3d11_c70e_4283_999d_6e34d993023f 'Microsoft.Web/sites/deployments@2024-11-01' = {
  parent: sites_app_backend_kidoikoiaki_name_resource
  name: 'f63a3d11-c70e-4283-999d-6e34d993023f'
  location: 'France Central'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'N/A'
    deployer: 'GITHUB_ZIP_DEPLOY'
    message: '{"type":"deployment","sha":"bacb05d77b8999d5fd02b62dec4087a32ada030e","repoName":"MMA-Project/Kidoikoiaki","actor":"helldeal","slotName":"production","commitMessage":"blob DefaultAzureCredential"}'
    start_time: '2026-02-05T15:55:01.8769973Z'
    end_time: '2026-02-05T15:56:01.7005825Z'
    active: false
  }
}

resource servers_ynov_sql_server_msimon_name_ynov_msimon_sql_Default 'Microsoft.Sql/servers/databases/advancedThreatProtectionSettings@2024-05-01-preview' = {
  parent: servers_ynov_sql_server_msimon_name_ynov_msimon_sql
  name: 'Default'
  properties: {
    state: 'Disabled'
  }
  dependsOn: [
    servers_ynov_sql_server_msimon_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_auditingSettings_servers_ynov_sql_server_msimon_name_ynov_msimon_sql_Default 'Microsoft.Sql/servers/databases/auditingSettings@2024-05-01-preview' = {
  parent: servers_ynov_sql_server_msimon_name_ynov_msimon_sql
  name: 'default'
  properties: {
    retentionDays: 0
    isAzureMonitorTargetEnabled: false
    state: 'Disabled'
    storageAccountSubscriptionId: '00000000-0000-0000-0000-000000000000'
  }
  dependsOn: [
    servers_ynov_sql_server_msimon_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_backupShortTermRetentionPolicies_servers_ynov_sql_server_msimon_name_ynov_msimon_sql_default 'Microsoft.Sql/servers/databases/backupShortTermRetentionPolicies@2024-05-01-preview' = {
  parent: servers_ynov_sql_server_msimon_name_ynov_msimon_sql
  name: 'default'
  properties: {
    retentionDays: 7
    diffBackupIntervalInHours: 12
  }
  dependsOn: [
    servers_ynov_sql_server_msimon_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_extendedAuditingSettings_servers_ynov_sql_server_msimon_name_ynov_msimon_sql_Default 'Microsoft.Sql/servers/databases/extendedAuditingSettings@2024-05-01-preview' = {
  parent: servers_ynov_sql_server_msimon_name_ynov_msimon_sql
  name: 'default'
  properties: {
    retentionDays: 0
    isAzureMonitorTargetEnabled: false
    state: 'Disabled'
    storageAccountSubscriptionId: '00000000-0000-0000-0000-000000000000'
  }
  dependsOn: [
    servers_ynov_sql_server_msimon_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_geoBackupPolicies_servers_ynov_sql_server_msimon_name_ynov_msimon_sql_Default 'Microsoft.Sql/servers/databases/geoBackupPolicies@2024-05-01-preview' = {
  parent: servers_ynov_sql_server_msimon_name_ynov_msimon_sql
  name: 'Default'
  properties: {
    state: 'Enabled'
  }
  dependsOn: [
    servers_ynov_sql_server_msimon_name_resource
  ]
}

resource storageAccounts_msimonblob_name_default_files 'Microsoft.Storage/storageAccounts/blobServices/containers@2025-01-01' = {
  parent: storageAccounts_msimonblob_name_default
  name: 'files'
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
  dependsOn: [
    storageAccounts_msimonblob_name_resource
  ]
}
