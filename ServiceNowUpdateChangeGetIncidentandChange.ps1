# Build Service Now Functions for Create, Update, and Get Incidents and Changes
# Chris Hildebrandt
# 11-25-2018
# Ver 1.0
# Script will create a new ServiceNow Incident and Change, Update existing Incidents and Changes, and Get all details of Incidents and Changes via Powershell
#______________________________________________________________________________________

#______________________________________________________________________________________
#ServiceNow Varibles
$SNAddress = "https://YOURSERVICENOW.service-now.com"

#______________________________________________________________________________________
#Incident Varribles
$SNINCCallerID = "Caller Sys_ID"
$SNINCUrgency = "2" #Look this up in your Service Now instance
$SNINCImpact = "3" #Look this up in your Service Now instance
$SNINCPriority = "4" #Look this up in your Service Now instance
$SNINCContactType = "email" #Look this up in your Service Now instance
$SNINCNotify = "2" #Look this up in your Service Now instance
$SNINCWatchlist = "Watch List Sys_ID" #Can do comma seperated users Sys_ID's
$SNINCServiceOffering = "Service Offering" #Look this up in your Service Now instance
$SNINCProductionImpact = "No" #Well I hope its a No. 
$SNINCCategory = "Your Catagory" #Look this up in your Service Now instance
$SNINCSubcategory = "Your SubCat" #Look this up in your Service Now instance 
$SNINCItem = "request" #Look this up in your Item menu
$SNINCAssignmentGroup = "Assignment Group Sys_ID"
$SNINCAssignedTo = "Assigned To Sys_ID"
$SNINCShortDescription = "Short Discription"
$SNINCDescription = "Full Discription"
$SNINCWorkNotes = "Work Notes"
$SNINComments = "Notes"

#______________________________________________________________________________________
#Change Varribles
$SNCHGRequestedBy = "Requested By Sys_ID"
$SNCHGCategory = "Change Catagory"  #Look this up in your Service Now instance
$SNCHGServiceOffering = "Service Offering"  #Look this up in your Service Now instance
$SNCHGReason = "Change Reason" #Look this up in your Service Now instance
$SNCHGClientImpact = "No" #Look this up in your Service Now instance
$SNCHGStartDate = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss') #date in string format. Only way it works.
$SNCHGEndDate = (Get-Date).AddHours($RCTimeDelay2+24).ToString('yyyy-MM-dd HH:mm:ss') #24 hour delay of right now (Can Change if needed) Has to be as a string
$SNCHGWatchList = "Watch List Sys_ID" #Can do comma seperated users Sys_ID's
$SNCHGUrgency = "2" #Look this up in your Service Now instance
$SNCHGRisk = "4" #Look this up in your Service Now instance
$SNCHGType = "Standard" #Look this up in your Service Now instance
$SNCHGState = "1" #Look this up in your Service Now instance
$SNCHGAssignmentGroup = "Assignment Group Sys_ID"
$SNCHGAssignedTo = "Assigned To Sys_ID"
$SNCHGShortDescription = "Short Description"
$SNCHGDescription = "Description Test"
$SNCHGJustification = "Justification  Notes"
$SNCHGChangePlan = "Change Plan"
$SNCHGTestPlan = "Test Plan Notes"
$SNCHGBackoutPlan = "Back Out Plan Notes"
$SNCHGChangeSummary = "Change Summary Notes"

#______________________________________________________________________________________
#Create Service Now Creds if they do not already exist

if(-Not (Test-Path -Path "C:\VDI_Tools\Scripts\SNAccount.txt" ))
{
    Get-Credential -Message "Enter Your ServiceNow Account! Username@domain" | Export-Clixml "C:\VDI_Tools\Scripts\SNAccount.txt"
    Write-Host "Created Secure Credentials for ServiceNow"
}

#______________________________________________________________________________________
#Import Service Now Creds
$SNCreds = Import-Clixml "C:\VDI_Tools\Scripts\SNAccount.txt"
Write-Host "Imported Secure Credentials for ServiceNow from Text file"

#______________________________________________________________________________________
#Decrypt Password to imput into ServiceNow
$SNTextPass = $SNCreds.Password | ConvertFrom-SecureString
$SNTextPassPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR( (ConvertTo-SecureString $SNTextPass) ))
Write-host "Decrypt Master Password to clear text for import into VM"

#______________________________________________________________________________________
#Create ServiceNow Creds Varribles
$SNuser = $SNCreds.Username
$SNpass = $SNTextPassPlain

#______________________________________________________________________________________
#ServiceNow Method Varibles Do not edit these
$SNMethodPost = "post"
$SNMethodGet = "get"
$SNMethodPut = "put"
$SNMethodPatch = "patch"

$SNINCAddress = "$SNAddress/api/now/table/incident"
$SNCHGAddress = "$SNAddress/api/now/table/change_request"

#______________________________________________________________________________________
#ServiceNow Build Auth Headers
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $SNuser, $SNpass)))

#______________________________________________________________________________________
#ServiceNow Set Header
$SNheaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$SNheaders.Add('Authorization',('Basic {0}' -f $base64AuthInfo))
$SNheaders.Add('Accept','application/json')
$SNheaders.Add('Content-Type','application/json')


Function Create-Incident()
{
# Specify request body
$SNCreateINCBody = @{ #Create Body of the Post Request
    caller_id= $SNINCCallerID
    urgency= $SNINCUrgency
    impact= $SNINCImpact
    priority= $SNINCPriority
    contact_type= $SNINCContactType
    notify= $SNINCNotify
    watch_list= $SNINCWatchlist
    service_offering= $SNINCServiceOffering
    u_production_impact= $SNINCProductionImpact
    category= $SNINCCategory
    subcategory= $SNINCSubcategory
    u_item= $SNINCItem
    assignment_group= $SNINCAssignmentGroup
    assigned_to= $SNINCAssignedTo
    short_description= $SNINCShortDescription
    description= $SNINCDescription
    work_notes= $SNINCWorkNotes
    comments= $SNINComments
}
$SNCreateINCbodyjson = $SNCreateINCBody | ConvertTo-Json

# POST to API
Try 
{
# Send API request
$SNCreateIncResponse = Invoke-RestMethod -Method $SNMethodPost -Uri $SNINCAddress -Body $SNCreateINCbodyjson -TimeoutSec 100 -Headers $SNheaders -ContentType "application/json"
}
Catch 
{
Write-Host $_.Exception.ToString()
$error[0] | Format-List -Force
}
return $SNCreateIncResponse
}

Function Create-Change()
{
#Specify Change Request Body
$SNCreateCHGbody = @{ #Create Body of the Post Request
    requested_by= $SNCHGRequestedBy
    category= $SNCHGCategory
    service_offering= $SNCHGServiceOffering
    reason= $SNCHGReason
    u_client_impact= $SNCHGClientImpact
    start_date= $SNCHGStartDate
    end_date= $SNCHGEndDate
    watch_list= $SNCHGWatchList
    parent= $SNIncidentSysID
    urgency= $SNCHGUrgency
    risk= $SNCHGRisk
    type= $SNCHGType
    state= $SNCHGState
    assignment_group= $SNCHGAssignmentGroup
    assigned_to= $SNCHGAssignedTo
    short_description= $SNCHGShortDescription
    description= $SNCHGDescription
    justification= $SNCHGJustification
    change_plan= $SNCHGChangePlan
    test_plan= $SNCHGTestPlan
    backout_plan= $SNCHGBackoutPlan
    u_change_summary= $SNCHGChangeSummary
}
$SNCreateCHGbodyjson = $SNCreateCHGbody | ConvertTo-Json

# POST to API
Try 
{
# Send API request
$SNCreateChangeResponse = Invoke-RestMethod -Method $SNMethodPost -Uri $SNCHGAddress -Body $SNCreateCHGbodyjson -TimeoutSec 100 -Headers $SNheaders -ContentType "application/json"
}
Catch 
{
Write-Host $_.Exception.ToString()
$error[0] | Format-List -Force
}
return $SNCreateChangeResponse
}

Function Update-Change($SNCHGUpdateComments)
{
# Specify request body
$SNUpdateCHGbody = @{ #Create Body of the Post Request
    comments= $SNCHGUpdateComments
}
$SNUpdateCHGbodyjson = $SNUpdateCHGbody | ConvertTo-Json

# Send API request
$SNUpdateChangeResponse = Invoke-RestMethod -Method $SNMethodPatch -Uri "$SNCHGAddress\$SNChangeSysID" -Body $SNUpdateCHGbodyjson -TimeoutSec 100 -Headers $SNheaders -ContentType "application/json"
}

Function Update-Incident($SNINCUpdateWorkNotesUpdate)
{
# Specify request body
$SNUpdateINCbody = @{ #Create Body of the Post Request
    work_notes= $SNINCUpdateWorkNotesUpdate
}
$SNUpdateINCbodyjson = $SNUpdateINCbody | ConvertTo-Json

# Send API request
$SNUpdateIncidentResponse = Invoke-RestMethod -Method $SNMethodPatch -Uri "$SNINCAddress\$SNIncidentSysID" -Body $SNUpdateINCbodyjson -TimeoutSec 100 -Headers $SNheaders -ContentType "application/json"
}

Function Get-Incident($SNGetIncidentSysID)
{
# Build URI
$SNGetINCAddress = "$SNINCAddress/$SNGetIncidentSysID" + "?sysparm_fields=parent%2Ccaused_by%2Cwatch_list%2Cu_aging_category%2Cu_call_back_number%2Cupon_reject%2Csys_updated_on%2Cu_resolved_by_tier_1%2Cu_ud_parent%2Cu_resolved_within_1_hour%2Cu_routing_rule%2Capproval_history%2Cskills%2Cu_actual_resolution_date%2Cnumber%2Cu_related_incidents%2Cu_closure_category%2Cstate%2Csys_created_by%2Cknowledge%2Corder%2Cdelivery_plan%2Ccmdb_ci%2Cimpact%2Cu_requested_for%2Cactive%2Cpriority%2Cgroup_list%2Cbusiness_duration%2Cu_template%2Capproval_set%2Cwf_activity%2Cu_requested_by_phone%2Cshort_description%2Cu_itil_watch_list%2Cdelivery_task%2Ccorrelation_display%2Cwork_start%2Cu_ca_reference%2Cadditional_assignee_list%2Cnotify%2Cservice_offering%2Csys_class_name%2Cfollow_up%2Cclosed_by%2Creopened_by%2Cu_csv_comments%2Cu_planned_response_date%2Creassignment_count%2Cassigned_to%2Csla_due%2Cu_actual_response_date%2Cu_sla_met%2Cu_closure_ci%2Cu_reopen_count%2Cescalation%2Cupon_approval%2Cu_service_category%2Ccorrelation_id%2Cu_resolution_duration%2Cu_requested_by_name%2Cmade_sla%2Cu_requested_by_email%2Cu_item%2Cu_svc_desk_created%2Cresolved_by%2Cu_business_service%2Csys_updated_by%2Cuser_input%2Copened_by%2Csys_created_on%2Csys_domain%2Cu_quality_impact%2Cu_req_count%2Ccalendar_stc%2Cclosed_at%2Cu_relationship%2Cu_parent_incident%2Cu_comments_and_work_notes%2Cu_requested_by_not_found%2Cu_requested_by%2Cbusiness_service%2Cu_agile_incident_ref%2Cu_symptom%2Crfc%2Ctime_worked%2Cexpected_start%2Copened_at%2Cwork_end%2Creopened_time%2Cresolved_at%2Ccaller_id%2Cu_client%2Cwork_notes%2Csubcategory%2Cu_ah_incident%2Cclose_code%2Cassignment_group%2Cbusiness_stc%2Cdescription%2Cu_planned_resolved_date%2Ccalendar_duration%2Cu_on_hold_type%2Cu_source%2Cclose_notes%2Cu_closure_subcategory%2Cu_previous_assignment%2Csys_id%2Ccontact_type%2Curgency%2Cproblem_id%2Cu_itil_group_list%2Cu_response_duration%2Cu_best_number%2Ccompany%2Cactivity_due%2Cseverity%2Cu_production_impact%2Ccomments%2Capproval%2Cdue_date%2Csys_mod_count%2Csys_tags%2Clocation%2Ccategory"

# Specify request body
$SNGetINCbody = @{ 
}
$SNGetINCbodyjson = $SNGetINCbody | ConvertTo-Json

# Send API request
$SNGetIncidentResponse = Invoke-RestMethod -Method $SNMethodGet -Headers $SNHeaders -Uri $SNGetINCAddress

Return $SNGetIncidentResponse
}

Function Get-Change($SNGetChangeSysID)
{
# Build URI
$SNGetCHGAddress = "$SNCHGAddress/$SNGetChangeSysID" + "?sysparm_fields=reason%2Cparent%2Cwatch_list%2Cu_aging_category%2Cproposed_change%2Cu_notification_form%2Cu_ah_change%2Cu_call_back_number%2Cupon_reject%2Csys_updated_on%2Ctype%2Cu_resolved_by_tier_1%2Cu_ud_parent%2Cu_resolved_within_1_hour%2Cu_routing_rule%2Capproval_history%2Cskills%2Ctest_plan%2Cu_actual_resolution_date%2Cnumber%2Cu_related_incidents%2Ccab_delegate%2Crequested_by_date%2Cu_business_impact%2Cu_validation_impact%2Cci_class%2Cstate%2Csys_created_by%2Cknowledge%2Corder%2Cphase%2Cdelivery_plan%2Ccmdb_ci%2Cimpact%2Cu_requested_for%2Cactive%2Cu_change_summary%2Cpriority%2Ccab_recommendation%2Cproduction_system%2Creview_date%2Cu_record_producer%2Crequested_by%2Cgroup_list%2Cbusiness_duration%2Cu_template%2Cchange_plan%2Capproval_set%2Cwf_activity%2Cimplementation_plan%2Cu_requested_by_phone%2Cstatus%2Cend_date%2Cshort_description%2Cu_itil_watch_list%2Cdelivery_task%2Ccorrelation_display%2Cwork_start%2Cu_ca_reference%2Coutside_maintenance_schedule%2Cadditional_assignee_list%2Cservice_offering%2Csys_class_name%2Cfollow_up%2Cclosed_by%2Cu_technical_impact%2Cu_depl_pkg_requested%2Cu_planned_response_date%2Creview_status%2Creassignment_count%2Cstart_date%2Cassigned_to%2Csla_due%2Cu_actual_response_date%2Cu_sla_met%2Cu_reopen_count%2Cescalation%2Cupon_approval%2Cu_service_category%2Ccorrelation_id%2Cu_resolution_duration%2Cu_requested_by_name%2Cmade_sla%2Cbackout_plan%2Cu_requested_by_email%2Cconflict_status%2Cu_item%2Cu_business_service%2Csys_updated_by%2Cuser_input%2Copened_by%2Csys_created_on%2Cu_cab_approval%2Csys_domain%2Cu_quality_impact%2Cu_req_count%2Cclosed_at%2Cu_relationship%2Creview_comments%2Cu_comments_and_work_notes%2Cu_requested_by_not_found%2Cu_requested_by%2Cbusiness_service%2Cu_symptom%2Ctime_worked%2Cexpected_start%2Copened_at%2Cwork_end%2Cphase_state%2Ccab_date%2Cwork_notes%2Csubcategory%2Cassignment_group%2Cdescription%2Cu_planned_resolved_date%2Cu_client_impact%2Ccalendar_duration%2Cu_on_hold_type%2Cclose_notes%2Csys_id%2Ccontact_type%2Ccab_required%2Cu_cab_yes%2Curgency%2Cscope%2Cu_itil_group_list%2Cu_response_duration%2Ccompany%2Cjustification%2Cactivity_due%2Ccomments%2Capproval%2Cdue_date%2Csys_mod_count%2Csys_tags%2Cconflict_last_run%2Crisk%2Clocation%2Ccategory%2Ccaused_by%2Cu_closure_category%2Cnotify%2Creopened_by%2Cu_csv_comments%2Cu_closure_ci%2Cu_svc_desk_created%2Cresolved_by%2Ccalendar_stc%2Cu_parent_incident%2Cu_agile_incident_ref%2Crfc%2Creopened_time%2Cresolved_at%2Ccaller_id%2Cu_client%2Cu_ah_incident%2Cclose_code%2Cbusiness_stc%2Cu_source%2Cu_closure_subcategory%2Cu_previous_assignment%2Cproblem_id%2Cu_best_number%2Cseverity%2Cu_production_impact"

# Specify request body
$SNGetCHGbody = @{ 
}
$SNGetCHGbodyjson = $SNGetCHGbody | ConvertTo-Json

# Send API request
$SNGetChangeResponse = Invoke-RestMethod -Method $SNMethodGet -Headers $SNHeaders -Uri $SNGetCHGAddress

Return $SNGetChangeResponse
}