//=============================================================================
// Logic App
//=============================================================================

//=============================================================================
// Imports
//=============================================================================

import { tagsType } from '../shared/types.bicep'

//=============================================================================
// Parameters
//=============================================================================

@description('Location to use for all resources')
param location string

@description('The tags to associate with the resource')
param tags tagsType

@description('The name of the App Service Plan')
param appServicePlanName string

@description('The name of the Logic App')
param logicAppName string

@description('The name of the service as used by azd')
param azdServiceName string

@description('Name of the storage account that will be used by the Logic App')
param storageAccountName string

//=============================================================================
// Variables
//=============================================================================

// azd uses the 'azd-service-name' tag to identify the service when deploying the app source code from the src folder.
// In this case the logic app workflow(s) and related assets.
var serviceTags { *: string } = union(tags, {
  'azd-service-name': azdServiceName
})

// Construct the storage account connection string
// NOTE: tried using a key vault secret but regularly got errors because the role assignment for the function app on the key vault was not yet effective
var storageAccountConnectionString string = 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'

var appSettings resourceInput<'Microsoft.Web/sites/config@2025-03-01'>.properties = {
  APP_KIND: 'workflowApp'
  AzureFunctionsJobHost__extensionBundle__id: 'Microsoft.Azure.Functions.ExtensionBundle.Workflows'
  AzureFunctionsJobHost__extensionBundle__version: '[1.*, 2.0.0)'
  AzureWebJobsStorage: storageAccountConnectionString
  FUNCTIONS_EXTENSION_VERSION: '~4'
  FUNCTIONS_WORKER_RUNTIME: 'dotnet'
  WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: storageAccountConnectionString
  WEBSITE_CONTENTSHARE: toLower(logicAppName)
  WEBSITE_NODE_DEFAULT_VERSION: '~22'
}

//=============================================================================
// Existing resources
//=============================================================================

resource hostingPlan 'Microsoft.Web/serverfarms@2025-03-01' existing = {
  name: appServicePlanName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2025-08-01' existing = {
  name: storageAccountName
}

//=============================================================================
// Resources
//=============================================================================

resource logicApp 'Microsoft.Web/sites@2025-03-01' = {
  name: logicAppName
  location: location
  tags: serviceTags
  kind: 'functionapp,workflowapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      // NOTE: the app settings will be set separately
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
      netFrameworkVersion: 'v8.0'
    }
    httpsOnly: true
  }
}

// Set standard App Settings
//  NOTE: this is done in a separate module that merges the app settings with the existing ones
//        to prevent other (manually) created app settings from being removed.

module setLogicAppSettings '../shared/merge-app-settings.bicep' = {
  params: {
    siteName: logicAppName
    currentAppSettings: list('${logicApp.id}/config/appsettings', logicApp.apiVersion).properties
    newAppSettings: appSettings
  }
}

//=============================================================================
// Outputs
//=============================================================================

output endpoint string = 'https://${logicApp.properties.defaultHostName}'
