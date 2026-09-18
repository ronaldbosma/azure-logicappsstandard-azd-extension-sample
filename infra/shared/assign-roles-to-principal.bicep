//=============================================================================
// Assign roles to principal on resources like Storage Account
//=============================================================================

//=============================================================================
// Parameters
//=============================================================================

@description('The id of the principal that will be assigned the roles')
param principalId string

@description('The type of the principal that will be assigned the roles')
param principalType string?

@description('The flag to determine if the principal is an admin or not')
param isAdmin bool = false

@description('The name of the Storage Account on which to assign roles')
param storageAccountName string

//=============================================================================
// Variables
//=============================================================================

var storageAccountRoleNames string[] = [
  'Storage Blob Data Contributor'
  isAdmin
    ? 'Storage File Data Privileged Contributor' // is able to browse file shares in Azure Portal
    : 'Storage File Data SMB Share Contributor'
  'Storage Queue Data Contributor'
  'Storage Table Data Contributor'
]

//=============================================================================
// Existing Resources
//=============================================================================

resource storageAccount 'Microsoft.Storage/storageAccounts@2026-04-01' existing = {
  name: storageAccountName
}

//=============================================================================
// Resources
//=============================================================================

// Assign roles on Storage Account to the principal

resource assignRolesOnStorageAccountToPrincipal 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for role in storageAccountRoleNames: {
    name: guid(storageAccount.id, principalId, roleDefinitions(role).id)
    scope: storageAccount
    properties: {
      roleDefinitionId: roleDefinitions(role).id
      principalId: principalId
      principalType: principalType
    }
  }
]
