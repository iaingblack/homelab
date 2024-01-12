# Lists current Keycloak users and account status
# From: https://github.com/moodysanalytics/ima-keycloak-ha-clients/blob/b52248b96a68b1582e907e1503ac7b0ffe0011c3/scripts/KeyCloakUsers.ps1
# ./ResetUserPassword.ps1 -keycloakuri='http://127.0.0.1:8080/auth/' -realmName 'Master' -keycloakUsername 'admin' -keycloakPassword 'Password1!' -username 'iain'
Param (
    [string] $keycloakUri = 'http://127.0.0.1:8080/auth/', # = $KeycloakURI,
    [string] $keycloakUsername = 'admin',
    [string] $keycloakPassword, # = $KeycloakAdminPassword,
    [string] $realmName = 'Master',
    [string] $username,
    [string] $resetToTemporaryPassword = 'true',
    [switch] $listUsers = $True,
    [switch] $resetPassword = $True
)

# Setup Powershell Connections
[System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# The token we get only allows authorization for one minute by default. Should be time for what we need, but just for info
function Get-BearerToken ($keycloakUri,  $keycloakUsername, $keycloakPassword  ) {
    $keycloakTokenURL = "$($keycloakUri)realms/master/protocol/openid-connect/token"
    $json = @{
        grant_type = 'password'
        client_id = 'admin-cli'
        username = $keycloakUsername
        password = $keycloakPassword
    }
    $response = Invoke-RestMethod $keycloakTokenURL -Method Post -Body $json -ContentType 'application/x-www-form-urlencoded'
    return $response.access_token
}

function RandomPwd($minLength=10, $maxLength=16, $seedString) {
    #Generates a pseudorandom string.
    $chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ0123456789abcdefghijkmnpqrstuvwxyz*()%&@'.ToCharArray()
    if ($seedString -ne $null) {
        $r = Get-Random -SetSeed ($seedString.ToLower().ToCharArray() | measure -Sum).sum
    }
    $pwd = (1..$(Get-Random -Minimum $minLength -Maximum $maxLength) | % {$chars | get-random}) -join ""
    $pwd = "$pwd!"
    return $pwd
}

function GetHeaders($accessToken) {
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Authorization", "Bearer $accessToken") | Out-Null
    $headers.Add("Accept", "application/json;odata=fullmetadata") | Out-Null
    return $headers
}

function GetKeycloakUsersList( $keycloakUri, $realmName, $accessToken) {
    $usersList = New-Object System.Collections.ArrayList
    $keycloakURL = "$($keycloakUri)admin/realms/$realmName/users"
    $headers = GetHeaders($accessToken)
    $response = Invoke-RestMethod $keycloakURL -Method Get -Headers $headers -ContentType 'application/x-www-form-urlencoded'
    foreach ($u in $response) {
        $usersList.add(@{"id"=$u.id ;"firstname"=$u.firstname ; "lastname"=$u.lastname ; "email"=$u.email ; "username"=$u.username ; "enabled"=$u.enabled ; "requiredActions"=$u.requiredActions} )| Out-Null
    }
    return $usersList
}

Write-Host "$keycloakUri"
$accessToken = Get-BearerToken -keycloakUri $keycloakUri -keycloakUsername $keycloakUsername -keycloakPassword $keycloakPassword

if ($listUsers)
{
    Write-Host "----------------------------------------------------------"
    Write-Host "Current Users"
    Write-Host "----------------------------------------------------------"
    $kkUsers = GetKeycloakUsersList $keycloakUri $realmName $accessToken
    foreach ($kkUser in $kkUsers) {
        if ($kkUser.requiredActions.count -gt 0) {
            $actions = "and actions are $($kkUser.requiredActions)"
        }
        else { $actions = "" }
        if ($kkUser.enabled -eq "True") { $status = "enabled" } else { $status = "DISABLED" }
        "$($kkUser.username) is $status $actions"
    }
}

# https://www.keycloak.org/docs-api/21.1.1/rest-api/
if ($resetPassword) {
    Write-Host "----------------------------------------------------------"
    Write-Host "Resetting Password for user $username"
    Write-Host "----------------------------------------------------------"
    $newUserPassword = RandomPWD
    $headers = GetHeaders($accessToken)
    $userFound = $False
    $kkUsers = GetKeycloakUsersList $keycloakUri $realmName $accessToken
    foreach ($kkUser in $kkUsers) {
        if ($kkUser.username -eq $username) {
            $userFound = $True
            Write-Host "User $username found"
            $keycloakPasswordResetURL = "$( $keycloakUri )admin/realms/$realmName/users/$( $kkUser.id )/reset-password"
            $json = "{""type"" :""password"", ""value"":""$newUserPassword"", ""temporary"": $resetToTemporaryPassword}"
            $response = Invoke-WebRequest $keycloakPasswordResetURL -Method Put  -Body ([System.Text.Encoding]::UTF8.GetBytes($json)) -Headers $headers -ContentType "application/json"
            if ($response.StatusCode -eq 204) {
                if ($resetToTemporaryPassword -eq 'true') { $isTemporary = ' temporary ' } else { $isTemporary = ' ' }
                Write-Host "New$($isTemporary)password for $($username) is: $newUserPassword"
            } else {
                $($response.RawContent)
                throw "Password reset failed for user '$($username)'"
            }
        }
    }
    if (!$userFound) {
        throw "User $username not found. Qutting."
    }
}
