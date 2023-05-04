# Application (client) ID, tenant Name and secret
$clientId = "456d146e-c675-4058-a7bb-3c26e06be533"
$tenantName = "5b808100-5f89-4e87-b816-634cd9906236"
$clientSecret = "lc28Q~Nt1p7qjcPDZRDHq~bVH8vXKPKRwl2lLcGX"
$resource = "https://graph.microsoft.com/"


$ReqTokenBody = @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    client_Id     = $clientID
    Client_Secret = $clientSecret
} 

$header = @{
        'Authorization'          = 'Bearer ' + $apiToken.access_token
        'X-Requested-With'       = 'XMLHttpRequest'
        'x-ms-client-request-id' = [guid]::NewGuid()
        'x-ms-correlation-id'    = [guid]::NewGuid()
}

$TokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantName/oauth2/v2.0/token" -Method POST -Body $ReqTokenBody

$UserUrl = "https://graph.microsoft.com/beta/users?$select=displayName"
$UserResponse = Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $UserUrl -Method Get -Verbose
$CloudUser = $UserResponse.Value
$UserNextLink = $UserResponse."@odata.nextLink"

while ($UserNextLink -ne $null) {

    $UserResponse = (Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $UserNextLink -Method Get -Verbose)
    $UserNextLink = $UserResponse."@odata.nextLink" #    ---> This line is the key!!!
    $CloudUser += $UserResponse.value
}

$CloudUser | Out-GridView

############# TESTING WITH DEVICES API #############

$DeviceUrl = "https://graph.microsoft.com/beta/devices"
$DevAccessToken = "eyJ0eXAiOiJKV1QiLCJub25jZSI6Ik01S<DhMc3hmenI5QkppdEg1dk9kOHl3S1hPdUhETDFIejJ2cXJoNXJzRXciLCJhbGciOiJSUzI1NiIsIng1dCI6IjJaUXBKM1VwYmpBWVhZR2FYRUpsOGxWMFRPSSIsImtpZCI6IjJaUXBKM1VwYmpBWVhZR2FYRUpsOGxWMFRPSSJ9.eyJhdWQiOiIwMDAwMDAwMy0wMDAwLTAwMDAtYzAwMC0wMDAwMDAwMDAwMDAiLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC81YjgwODEwMC01Zjg5LTRlODctYjgxNi02MzRjZDk5MDYyMzYvIiwiaWF0IjoxNjY2NDkxNDc5LCJuYmYiOjE2NjY0OTE0NzksImV4cCI6MTY2NjQ5NjAyNywiYWNjdCI6MCwiYWNyIjoiMSIsImFpbyI6IkFVUUF1LzhUQUFBQVZqZnlsZEtLU0l3QlM4eElBN1NYVEtzSmFHcGRqcXpKaS81dmN4aHlNZXBuc0pQcjY2dnZNWVlPOVpzVTNvOVlMOVZkSDltZWEvRVo4RzZjRnc1dUpBPT0iLCJhbXIiOlsicHdkIl0sImFwcF9kaXNwbGF5bmFtZSI6IkdyYXBoIEV4cGxvcmVyIiwiYXBwaWQiOiJkZThiYzhiNS1kOWY5LTQ4YjEtYThhZC1iNzQ4ZGE3MjUwNjQiLCJhcHBpZGFjciI6IjAiLCJmYW1pbHlfbmFtZSI6IllvcG9sbyIsImdpdmVuX25hbWUiOiJGZXJuYW5kbyIsImlkdHlwIjoidXNlciIsImlwYWRkciI6IjE5MC44LjE4NC4xNzUiLCJuYW1lIjoiRmVybmFuZG8gWW9wb2xvIiwib2lkIjoiYTA3MDkxNmUtMjRhYi00MzY1LWE2ODEtZTkwZTc1ZTM1MDFhIiwib25wcmVtX3NpZCI6IlMtMS01LTIxLTI1MDY5ODQwMTAtNjU0ODkwMjg4LTY1MDQzNzM5MS0zMjM4MyIsInBsYXRmIjoiMyIsInB1aWQiOiIxMDAzMjAwMUUzQTNDRDMxIiwicmgiOiIwLkFSc0FBSUdBVzRsZmgwNjRGbU5NMlpCaU5nTUFBQUFBQUFBQXdBQUFBQUFBQUFBYkFJRS4iLCJzY3AiOiJBY2Nlc3NSZXZpZXcuUmVhZC5BbGwgQWNjZXNzUmV2aWV3LlJlYWRXcml0ZS5BbGwgQWdyZWVtZW50LlJlYWQuQWxsIEFncmVlbWVudC5SZWFkV3JpdGUuQWxsIEFncmVlbWVudEFjY2VwdGFuY2UuUmVhZCBBZ3JlZW1lbnRBY2NlcHRhbmNlLlJlYWQuQWxsIEFuYWx5dGljcy5SZWFkIEFwcENhdGFsb2cuUmVhZFdyaXRlLkFsbCBBcHByb3ZhbFJlcXVlc3QuUmVhZC5BZG1pbkNvbnNlbnRSZXF1ZXN0IEFwcHJvdmFsUmVxdWVzdC5SZWFkLkN1c3RvbWVyTG9ja2JveCBBcHByb3ZhbFJlcXVlc3QuUmVhZC5FbnRpdGxlbWVudE1hbmFnZW1lbnQgQXBwcm92YWxSZXF1ZXN0LlJlYWQuUHJpdmlsaWdlZEFjY2VzcyBBcHByb3ZhbFJlcXVlc3QuUmVhZFdyaXRlLkFkbWluQ29uc2VudFJlcXVlc3QgQXBwcm92YWxSZXF1ZXN0LlJlYWRXcml0ZS5DdXN0b21lckxvY2tib3ggQXBwcm92YWxSZXF1ZXN0LlJlYWRXcml0ZS5FbnRpdGxlbWVudE1hbmFnZW1lbnQgQXBwcm92YWxSZXF1ZXN0LlJlYWRXcml0ZS5Qcml2aWxpZ2VkQWNjZXNzIEF1ZGl0TG9nLlJlYWQuQWxsIEJpdGxvY2tlcktleS5SZWFkLkFsbCBCaXRsb2NrZXJLZXkuUmVhZEJhc2ljLkFsbCBEZXZpY2UuUmVhZC5BbGwgRGV2aWNlTWFuYWdlbWVudEFwcHMuUmVhZC5BbGwgRGV2aWNlTWFuYWdlbWVudEFwcHMuUmVhZFdyaXRlLkFsbCBEZXZpY2VNYW5hZ2VtZW50Q29uZmlndXJhdGlvbi5SZWFkLkFsbCBEZXZpY2VNYW5hZ2VtZW50Q29uZmlndXJhdGlvbi5SZWFkV3JpdGUuQWxsIERldmljZU1hbmFnZW1lbnRNYW5hZ2VkRGV2aWNlcy5SZWFkLkFsbCBEZXZpY2VNYW5hZ2VtZW50TWFuYWdlZERldmljZXMuUmVhZFdyaXRlLkFsbCBEZXZpY2VNYW5hZ2VtZW50UkJBQy5SZWFkLkFsbCBEZXZpY2VNYW5hZ2VtZW50UkJBQy5SZWFkV3JpdGUuQWxsIERldmljZU1hbmFnZW1lbnRTZXJ2aWNlQ29uZmlnLlJlYWQuQWxsIERldmljZU1hbmFnZW1lbnRTZXJ2aWNlQ29uZmlnLlJlYWRXcml0ZS5BbGwgb3BlbmlkIHByb2ZpbGUgVXNlci5SZWFkIFVzZXIuUmVhZC5BbGwgVXNlci5SZWFkQmFzaWMuQWxsIGVtYWlsIERpcmVjdG9yeS5SZWFkV3JpdGUuQWxsIiwic2lnbmluX3N0YXRlIjpbImttc2kiXSwic3ViIjoiZlNYTndKcFlnRkRUemlRQ3FiOXd3eU9aTEdjRzdRTWNkVWpkYWc1ODl0SSIsInRlbmFudF9yZWdpb25fc2NvcGUiOiJOQSIsInRpZCI6IjViODA4MTAwLTVmODktNGU4Ny1iODE2LTYzNGNkOTkwNjIzNiIsInVuaXF1ZV9uYW1lIjoiRmVybmFuZG8uWW9wb2xvQGFsZXJhZ3JvdXAuY29tIiwidXBuIjoiRmVybmFuZG8uWW9wb2xvQGFsZXJhZ3JvdXAuY29tIiwidXRpIjoidGRQa0I2M0N6azJ2VW5RWjNHc1VBQSIsInZlciI6IjEuMCIsIndpZHMiOlsiZTM5NzNiZGYtNDk4Ny00OWFlLTgzN2EtYmE4ZTIzMWM3Mjg2IiwiOWYwNjIwNGQtNzNjMS00ZDRjLTg4MGEtNmVkYjkwNjA2ZmQ4IiwiM2EyYzYyZGItNTMxOC00MjBkLThkNzQtMjNhZmZlZTVkOWQ1IiwiNjJlOTAzOTQtNjlmNS00MjM3LTkxOTAtMDEyMTc3MTQ1ZTEwIiwiZmU5MzBiZTctNWU2Mi00N2RiLTkxYWYtOThjM2E0OWEzOGIxIiwiNzY5OGE3NzItNzg3Yi00YWM4LTkwMWYtNjBkNmIwOGFmZmQyIiwiYjc5ZmJmNGQtM2VmOS00Njg5LTgxNDMtNzZiMTk0ZTg1NTA5Il0sInhtc19zdCI6eyJzdWIiOiJicDlWRXV2ME43c2ZTM2dPUEpZbjl1TWtfYUpIX0g1VzVCc3dPZ3cyNExjIn0sInhtc190Y2R0IjoxNDg0ODM5NDc5fQ.REGIwippA-wFvBRCMboQlKvDnZ86-3s7fJKkyGdqjTRdnah3X3110cMc9D3xWzZZ8WJmOhF8tC9Ie1qdciX3RVuYsUOUiM9E9R2tNHUFzQH8E6VRVylwuoWPp1b6nGkN2Az6dbTxbqPjbizo82inflsu0FloQCUfKIGL0Qvi4Xw7ITaAhJ-JbmAPjJbFkW0eEMD-0PPQEu-MrAADoP_2rFy5IG9h4g2LRJcL3yQSkoYe3V-41mqUL4l6LQ8kW2qU8WIamiwQCqenVEwsY44v2oM3FYjmpol_3MEdiEb8lkVeKNo_VIIiFt4uuvQPdhYu0gtBlW5WnlnK00q6vkz1bA"

$DeviceResponse = Invoke-RestMethod -Headers @{Authorization = "Bearer $($DevAccessToken)"} -Uri $DeviceUrl -Method Get -Verbose
$DeviceTest = $DeviceResponse.value | Where-Object {$_.operatingSystem -eq "Windows" -and $_.managementType -ne "MDM"}
$DeviceNextLink = $DeviceResponse."@odata.nextLink"

$DeviceTest2 = $DeviceResponse.value | Where-Object {$_.displayName -eq "ZIN-CShaud"}

$DeviceTest | Out-GridView

$Bitlocker1 = "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations"
$BLResponse = Invoke-RestMethod -Headers @{Authorization = "Bearer $($DevAccessToken)"} -Uri $Bitlocker1 -Method Get -Verbose
$BLResponse.value | Out-GridView

$Bitlocker2 = "https://graph.microsoft.com/beta/informationProtection/bitlocker/recoveryKeys?"
$BLResponse2 = Invoke-RestMethod -Headers @{Authorization = "Bearer $($DevAccessToken)"} -Uri $Bitlocker2 -Method Get -Verbose
$BLResponse2.value

$BLResponse2.value | Out-GridView

Invoke-MSGraphOperation -Get -APIVersion "Beta" -Resource "/devices" -Headers $header

# Connect-MSGraph -ForceInteractive
# Get-MgInformationProtectionBitlockerRecoveryKey

Connect-MgGraph -ClientId "456d146e-c675-4058-a7bb-3c26e06be533" -TenantId "5b808100-5f89-4e87-b816-634cd9906236"
Get-MgInformationProtectionBitlockerRecoveryKey -BitlockerRecoveryKeyId "ad5eb0e5-3a77-4051-9ec4-32b2263e49df" -Property "key"
Get-MgDevice -All



$BitlockerUrlTest = "https://graph.microsoft.com/beta/informationProtection/bitlocker/recoveryKeys/{bitlockerRecoveryKey-id}"

Find-MgGraphCommand -Uri "/bitlocker/recoverykeys?" -Method "POST"

# Disconnect-MgGraph