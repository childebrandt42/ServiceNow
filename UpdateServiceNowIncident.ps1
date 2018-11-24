# Update Existing ServiceNow Incident
# Chris Hildebrandt
# 10-26-2018
# Ver 1.0
# Script will update existing ServiceNow Incident via Powershell
#______________________________________________________________________________________

#______________________________________________________________________________________
#ServiceNow creds
$user = "admin"
$pass = "admin"

# Build auth header
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $user, $pass)))

# Set proper headers
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add('Authorization',('Basic {0}' -f $base64AuthInfo))
$headers.Add('Accept','application/json')
$headers.Add('Content-Type','application/json')

# Specify endpoint uri
$uri = "https://YOURSERVICENOW.service-now.com/api/now/table/incident/YourINCIDENTSys_ID"

# Specify HTTP method
$method = "patch"

# Specify request body
$body = @{ #Create Body of the Post Request
work_notes="Update Work Notes"
close_notes="Your Close Notes"
}

$bodyjson = $body | ConvertTo-Json

# Send HTTP request
$response = Invoke-WebRequest -Headers $headers -Method $method -Uri $uri -Body $bodyjson -ContentType "application/json"

# Print response
$response.RawContent