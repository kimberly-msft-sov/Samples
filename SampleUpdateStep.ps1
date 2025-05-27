# Step 1: Import the module (if not already loaded)
#Import-Module Microsoft.Xrm.Tooling.CrmConnector.PowerShell
#Install-Module -Name Microsoft.PowerApps.Administration.PowerShell
#Install-Module -Name Microsoft.PowerApps.PowerShell -AllowClobber

$conn = Get-CrmConnection -ConnectionString `
"AuthType=OAuth;
 Url=https://<yourorg>.crm9.dynamics.com;
 AppId=<yourappid>;
 RedirectUri=<your redirect uri>;"

 #SAMPLE
 #$conn = Get-CrmConnection -ConnectionString `
#"AuthType=OAuth;
 #Url=https://orge9g1p34e.crm9.dynamics.com;
 #AppId=43522343-1234-5678-aaae-a2591f434a12e;
 #RedirectUri=app://58dfwB91-0ds6-3200-8234-0834234F2AC97;"

# Create an environment variable in your solution
# Retrieve the SystemUserId for the App User and store the guid in the environment variable
# I matched on part of the # app user name
$appuser = Get-CrmRecords -EntityLogicalName "systemuser" -Fields "fullname","systemuserid" -FilterAttribute "fullname" -FilterOperator like -FilterValue "%# <part of app user name here>%"
$appuser.CrmRecords
#$appuser.CrmRecords[0].systemuserid

# Get the environment variable definition
$envvar = Get-CrmRecords -EntityLogicalName environmentvariabledefinition -FilterAttribute schemaname -FilterOperator eq -FilterValue "<envvar schema name>" -conn $conn

# Get the value
$envvarid = $envvar.CrmRecords[0].environmentvariabledefinitionid
$value = Get-CrmRecords -EntityLogicalName environmentvariablevalue -FilterAttribute environmentvariabledefinitionid -FilterOperator eq -FilterValue $definitionId -Fields "value" -conn $conn
$appuserid = $value.CrmRecords[0].value


#You'll need to determine what logic to use to determine what steps to update
#This example is matching on the name containing "Basic"
$steps = Get-CrmRecords -EntityLogicalName "sdkmessageprocessingstep" -Fields "name", "sdkmessageprocessingstepid","impersonatinguserid" -FilterAttribute "name" -FilterOperator like -FilterValue "%Basic%"
$steps.CrmRecords[0]

#For testing I entered the GUID here
$sdkStepId = "<enter step guid here>"

$lookup = New-Object Microsoft.Xrm.Sdk.EntityReference("systemuser", [Guid]::Parse($appuserid))

# Update the plugin step
Set-CrmRecord -EntityLogicalName "sdkmessageprocessingstep" -Id $sdkStepId -Fields @{ "impersonatinguserid" = $lookup }

Write-Host "✅ Plugin step updated with new ImpersonatingUserId." -ForegroundColor Green



