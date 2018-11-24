# Update New ServiceNow Change
# Chris Hildebrandt
# 10-26-2018
# Ver 1.0
# Script will Update a ServiceNow Change via Powershell
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
$UpdateCHGuri = "https://YOURSERVICENOW.service-now.com/api/now/table/change_request/THE Change you want to updates Sys_ID"

# Specify HTTP method
$Patchmethod = "patch"

# Specify request body
$UpdateCHGbody = @{ #Create Body of the Post Request
    state = "8"
    comments = "Additional Coments " #Add the comments you want to add to the Change.
    u_change_summary = "Change Summary" #Add to the Change Summary. 
}
$UpdateCHGbodyjson = $UpdateCHGbody | ConvertTo-Json
# Send HTTP request
$response = Invoke-WebRequest -Headers $headers -Method $method -Uri $uri -Body $body

# Send API request
$UpdateChangePOSTResponse = Invoke-RestMethod -Method $Patchmethod -Uri $UpdateCHGuri -Body $UpdateCHGbodyjson -TimeoutSec 100 -Headers $headers -ContentType "application/json"