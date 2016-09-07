

Param(
    [string] $ResourceGroupName = 'Premium',
    [string] $ResourceLocation = 'eastus',
    [string] $api = 'twitter',
    [string] $ConnectionName = 'twittertest',
    [string] $subscriptionId = '80d4fe69-c95b-4dd2-a938-9250f1c8ab03',
 #   [string] $ADobjectId =  $null,
    [bool] $createConnection =  $true
)
 #region mini window, made by Scripting Guy Blog
    Function Show-OAuthWindow {
    Add-Type -AssemblyName System.Windows.Forms
 
    $form = New-Object -TypeName System.Windows.Forms.Form -Property @{Width=600;Height=800}
    $web  = New-Object -TypeName System.Windows.Forms.WebBrowser -Property @{Width=580;Height=780;Url=($url -f ($Scope -join "%20")) }
    $DocComp  = {
            $Global:uri = $web.Url.AbsoluteUri
            if ($Global:Uri -match "error=[^&]*|code=[^&]*") {$form.Close() }
    }
    $web.ScriptErrorsSuppressed = $true
    $web.Add_DocumentCompleted($DocComp)
    $form.Controls.Add($web)
    $form.Add_Shown({$form.Activate()})
    $form.ShowDialog() | Out-Null
    }
    #endregion

#login to get an access code 

Login-AzureRmAccount 

#select the subscription

$subscription = Select-AzureRmSubscription -SubscriptionId $subscriptionId

#can try to automatically get objectId
# $user = Get-AzureRmADUser -Mail 'myemail@foo.com'
# $ADobjectId = $user.Id

#if the connection wasn't alrady created via a deployment
if($createConnection)
{
    $connection = New-AzureRmResource -Properties @{"api" = @{"id" = "subscriptions/" + $subscriptionId + "/providers/Microsoft.Web/locations/" + $ResourceLocation + "/managedApis/" + $api}; "displayName" = $ConnectionName; } -ResourceName $ConnectionName -ResourceType "Microsoft.Web/connections" -ResourceGroupName $ResourceGroupName -Location $ResourceLocation -Force
}
#else (meaning the conneciton was created via a deployment) - get the connection
else{
$connection = Get-AzureRmResource -ResourceType "Microsoft.Web/connections" -ResourceGroupName $ResourceGroupName -ResourceName $ConnectionName
}
Write-Host "connection status: " $connection.Properties.Statuses[0]

$parameters = @{
	"parameters" = ,@{
	"parameterName"= "token";
	"redirectUrl"= "https://ema1.exp.azure.com/ema/default/authredirect"
	}
}
# $parameters.parameters[0].Add("objectId", $null)
# $parameters.parameters[0].Add("tenantId", $null)

#get the links needed for consent
$consentResponse = Invoke-AzureRmResourceAction -Action "listConsentLinks" -ResourceId $connection.ResourceId -Parameters $parameters -Force

$url = $consentResponse.Value.Link 

#prompt user to login and grab the code after auth
Show-OAuthWindow -URL $url

$regex = '(code=)(.*)$'
    $code  = ($uri | Select-string -pattern $regex).Matches[0].Groups[2].Value
    Write-output "Received an accessCode: $code"

if (-Not [string]::IsNullOrEmpty($code)) {
	$parameters = @{ }
	$parameters.Add("code", $code)#
#	$parameters.Add("objectId", $null)
#	$parameters.Add("tenantId", $null)
	# NOTE: errors ignored as this appears to error due to a null response

    #confirm the consent code
	Invoke-AzureRmResourceAction -Action "confirmConsentCode" -ResourceId $connection.ResourceId -Parameters $parameters -Force -ErrorAction Ignore
}

#retrieve the connection
$connection = Get-AzureRmResource -ResourceType "Microsoft.Web/connections" -ResourceGroupName $ResourceGroupName -ResourceName $ConnectionName
Write-Host "connection status now: " $connection.Properties.Statuses[0]