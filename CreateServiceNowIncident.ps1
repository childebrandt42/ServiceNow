# Create New ServiceNow Incident
# Chris Hildebrandt
# 10-26-2018
# Ver 1.0
# Script will create a new ServiceNow Incident via Powershell
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
$uri = "https://YOURSERVICENOW.service-now.com/api/now/table/incident"

# Specify HTTP method
$method = "post"

# Specify request body
$body = @{ #Create Body of the Post Request
    caller_id= "The Caller Sys_ID"
    urgency= "2"
    impact= "3"
    priority= "4"
    contact_type= "email"
    notify= "2"
    watch_list= "Watch List Sys_ID"
    service_offering= "Service Offering 32 Char Sys_ID"
    u_production_impact= "No"
    category= "Your Catagory Find from the drop down menu"
    subcategory= "Find the subcategory from the list"
    u_item= "request"   #Check the Drop down for the options
    assignment_group= "Assignment Group 32 Char Sys_ID"
    assigned_to= "Assigned to Sys_ID"
    short_description= "Short Description of the Incident"
    description= "Description of the Incident"
    work_notes= "Work Notes"
    comments= "Additional Comments and Notes"

}
$bodyjson = $body | ConvertTo-Json

# Send HTTP request
$CreateServiceIncident = Invoke-WebRequest -Headers $headers -Method $method -Uri $uri -Body $bodyjson -ContentType "application/json"

# Print response
$CreateServiceIncident.RawContent