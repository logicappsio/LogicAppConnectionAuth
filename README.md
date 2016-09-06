# LogicAppConnectionAuth
PowerShell Script to get an authorization link and complete auth for an OAuth connector.

## What this script does

This script will retrieve a consent link for a connection (and can also create the connection at the same time) for an OAuth Logic Apps connector.  It will then open the consent link and complete authorization to enable a connection.  This can be used after deployment of connections to make sure a Logic App is working end-to-end.

## How to use

Run this script and substitute out parameters as needed:

| Name | Description |
| --- | --- |
| ResourceGroupName | Name of the resource group for the connection |
| ResourceLocation | Location of the resource group |
| api | The name of the api to generate a connection for |
| ConnectionName | Name of the connection resource to create or generate authorization for |
| SubscriptionId | Azure Subscription ID to use for connection creation/authorization |
| ADObjectId | The Object ID for the AD User making the request to get a token |
| createConnection | set to `false` if the connection was already deployed |

## How to get the `ADObjectId`

1. Go to the [Azure Active Directory](https://manage.windowsazure.com) portion for the subscription and click on the **Active Directory** section.  
1. Select the Directory
1. Select **Users**
1. Select the user you will be logging in as
1. Copy the **Object ID** property and paste in script

You can also attempt to retrieve the user from PowerShell directly by un-commenting the following code and replacing the `-Mail` value with the email of the AD user. 

```PowerShell
$user = Get-AzureRmADUser -Mail 'myemail@foo.com'
$ADobjectId = $user.Id
```