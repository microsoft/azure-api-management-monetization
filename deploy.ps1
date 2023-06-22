[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]
    $TenantId,

    [Parameter(Mandatory=$true)]
    [string]
    $SubscriptionId,

    [Parameter(Mandatory=$true)]
    [string]
    $ResourceGroupName,

    [Parameter(Mandatory=$true)]
    [string]
    $ResourceGroupLocation,

    [Parameter(Mandatory=$true)]
    [string]
    $ArtifactStorageAccountName,

    [Parameter()]
    [string]
    $ParameterFilePath = "$(Split-Path -Parent $PSCommandPath)/output/devtest.parameters.json"
)

$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $PSCommandPath

$deploymentName = "ApimMonetization{0}" -f (Get-Date).ToString("yyyyMMddHHmmss")

$account = (az account show) | ConvertFrom-Json

if (!$account -or $account.tenantId -ne $TenantId) {
    az login --tenant $TenantId
}

if ($account.id -ne $SubscriptionId) {
    az account set --subscription $SubscriptionId
}

az group create --name $ResourceGroupName --location $ResourceGroupLocation

az storage account create -n $ArtifactStorageAccountName -g $ResourceGroupName -l $ResourceGroupLocation
az storage container create -n default --account-name $ArtifactStorageAccountName --public-access blob
az storage blob directory upload -c default --account-name $ArtifactStorageAccountName -s "$here/apiConfiguration/*" -d "/apiConfiguration" --recursive
az storage blob directory upload -c default --account-name $ArtifactStorageAccountName -s "$here/payment/*" -d "/payment" --recursive
$artifactsBaseUrl = "https://$ArtifactStorageAccountName.blob.core.windows.net/default"

az deployment group create --resource-group $ResourceGroupName --name $deploymentName --template-file "$here/output/main.json" --parameters (Resolve-Path $ParameterFilePath) --parameters artifactsBaseUrl=$artifactsBaseUrl