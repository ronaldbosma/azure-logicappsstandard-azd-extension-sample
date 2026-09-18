//=============================================================================
// Sample template to demonstrate azure.logicappsstandard azd extension
//=============================================================================

targetScope = 'subscription'

//=============================================================================
// Imports
//=============================================================================

import { getResourceName, generateInstanceId } from 'shared/naming-conventions.bicep'
import { tagsType } from 'shared/types.bicep'

//=============================================================================
// Parameters
//=============================================================================

@minLength(1)
@description('Location to use for all resources')
param location string

@minLength(1)
@maxLength(32)
@description('The name of the environment to deploy to')
param environmentName string

//=============================================================================
// Variables
//=============================================================================

// Generate an instance ID to ensure unique resource names
var instanceId string = generateInstanceId(environmentName, location)

var resourceGroupName string = getResourceName('resourceGroup', environmentName, location, instanceId)
var appServicePlanName = getResourceName('appServicePlan', environmentName, location, 'logicapp-${instanceId}')
var logicAppWithoutCodeName = getResourceName('logicApp', environmentName, location, 'withoutcode-${instanceId}')
var logicAppWithCodeName = getResourceName('logicApp', environmentName, location, 'withcode-${instanceId}')
var storageAccountName string = getResourceName('storageAccount', environmentName, location, instanceId)

var tags tagsType = {
  'azd-env-name': environmentName
  'azd-template': 'ronaldbosma/azure-logicappsstandard-azd-extension-sample'
}

//=============================================================================
// Resources
//=============================================================================

resource resourceGroup 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

module storageAccount 'modules/storage-account.bicep' = {
  scope: resourceGroup
  params: {
    location: location
    tags: tags
    storageAccountName: storageAccountName
  }
}

module appServicePlan 'modules/app-service-plan.bicep' = {
  scope: resourceGroup
  params: {
    location: location
    tags: tags
    appServicePlanName: appServicePlanName
  }
}

module logicAppWithoutCode 'modules/logic-app.bicep' = {
  scope: resourceGroup
  params: {
    location: location
    tags: tags
    appServicePlanName: appServicePlanName
    azdServiceName: 'logicAppWithoutCode'
    logicAppName: logicAppWithoutCodeName
    storageAccountName: storageAccountName
  }
  dependsOn: [
    appServicePlan
    storageAccount
  ]
}

module logicAppWithCode 'modules/logic-app.bicep' = {
  scope: resourceGroup
  params: {
    location: location
    tags: tags
    appServicePlanName: appServicePlanName
    azdServiceName: 'logicAppWithCode'
    logicAppName: logicAppWithCodeName
    storageAccountName: storageAccountName
  }
  dependsOn: [
    appServicePlan
    storageAccount
  ]
}

module assignRolesToDeployer 'shared/assign-roles-to-principal.bicep' = {
  scope: resourceGroup
  params: {
    principalId: deployer().objectId
    storageAccountName: storageAccountName
  }
  dependsOn: [
    storageAccount
  ]
}

//=============================================================================
// Outputs
//=============================================================================

// Return the Azure tenant id so it is available in the .env file and can be used in e.g. the integration tests
output AZURE_TENANT_ID string = subscription().tenantId

// Return the names of the resources
output AZURE_LOGIC_APP_WITHOUT_CODE_NAME string = logicAppWithoutCodeName
output AZURE_LOGIC_APP_WITH_CODE_NAME string = logicAppWithCodeName
output AZURE_STORAGE_ACCOUNT_NAME string = storageAccountName
