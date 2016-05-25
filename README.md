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
| createConnection | set to `false` if the connection was already deployed |
