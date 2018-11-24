# Create New ServiceNow Change
# Chris Hildebrandt
# 10-26-2018
# Ver 1.0
# Script will create a new ServiceNow Change via Powershell
#______________________________________________________________________________________

# Eg. User name="admin", Password="admin" for this code sample.
$SNuser = "admin" #enter your ServiceNow Username
$SNpass = "admin" #enter your ServiceNow Password

# Build auth header
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $SNuser, $SNpass)))

# Set proper headers
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add('Authorization',('Basic {0}' -f $base64AuthInfo))
$headers.Add('Accept','application/json')
$headers.Add('Content-Type','application/json')

# Specify endpoint uri
$CHGuri = "https://YOURSERVICENOW.service-now.com/api/now/table/change_request"

# Specify HTTP method
$Postmethod = "post"


# Specify request body
$CHGbody = @{ #Create Body of the Post Request
requested_by = "Requested By Sys_ID"
category = "Other"
service_offering = "Other"
reason = "software upgrade"
u_client_impact = "No"
start_date = "2018-11-1 01:00:00"
end_date = "2018-11-30 23:00:00"
watch_list = "Watch List Sys_ID"
parent = "Parent Incident or Change Request"
urgency = "2"
risk = "4"
type = "Standard"
state = "1"
assignment_group = "Assigned To's Group Sys_ID"
assigned_to = "Assigned To Sys_ID"
short_description = "Short Description"
description = "Description: Test"
justification = "Justification  Notes"
change_plan = "Change Plan:"
test_plan = "Test Plan: Notes"
backout_plan = "Back Out Plan: Notes"
u_change_summary = "Change Summary: Notes"
}

$CHGbodyjson = $CHGbody | ConvertTo-Json

# POST to API
Try 
{
# Send API request
$ChangePOSTResponse = Invoke-RestMethod -Method $Postmethod -Uri $CHGuri -Body $CHGbodyjson -TimeoutSec 100 -Headers $headers -ContentType "application/json"
}
Catch 
{
Write-Host $_.Exception.ToString()
$error[0] | Format-List -Force
}
# Pulling ticket ID from response
$ChangeID = $ChangePOSTResponse.result.number
$ChangeSysID = $ChangePOSTResponse.result.sys_id

# Verifying Change created and show ID
IF ($ChangeID -ne $null)
{
"Created Change With ID:$ChangeID"
"Change created With Sys_ID:$ChangeSysID"
}
ELSE
{
"Change Not Created"
}