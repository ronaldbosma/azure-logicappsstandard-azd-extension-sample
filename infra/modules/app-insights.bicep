//=============================================================================
// Application Insights
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

@description('The name of the App Insights instance')
param appInsightsName string

@description('The name of the Log Analytics workspace')
param logAnalyticsWorkspaceName string

@description('The retention period for the logs in days')
param retentionInDays int = 30

//=============================================================================
// Resources
//=============================================================================

// Log Analytics Workspace

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2025-07-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  tags: tags
  properties: {
    retentionInDays: retentionInDays
    sku: {
      name: 'PerGB2018'
    }
    features: {
      disableLocalAuth: true // Disable Non-EntraID based Auth
    }
  }
}

// Application Insights

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    WorkspaceResourceId: logAnalyticsWorkspace.id
    RetentionInDays: retentionInDays
    DisableLocalAuth: true // Disable Non-EntraID based Auth
  }
}
