//=============================================================================
// App Service Plan
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

//=============================================================================
// Resources
//=============================================================================

resource hostingPlan 'Microsoft.Web/serverfarms@2025-03-01' = {
  name: appServicePlanName
  location: location
  tags: tags
  kind: 'elastic'
  sku: {
    name: 'WS1'
    tier: 'WorkflowStandard'
  }
  properties: {
    elasticScaleEnabled: false
  }
}
