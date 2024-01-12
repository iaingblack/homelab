function BannerMessage($text) {
    Write-Host "----------------------------------------------------------"
    Write-Host $text
    Write-Host "----------------------------------------------------------"
}

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

function GetKeycloakUsersList($keycloakUri, $realmName, $accessToken) {
    $usersList = New-Object System.Collections.ArrayList
    $keycloakURL = "$($keycloakUri)admin/realms/$realmName/users"
    $headers = GetHeaders -accessToken $accessToken
    $response = Invoke-RestMethod $keycloakURL -Method Get -Headers $headers -ContentType 'application/x-www-form-urlencoded'
    foreach ($u in $response) {
        $usersList.add(@{"id"=$u.id ;"firstname"=$u.firstname ; "lastname"=$u.lastname ; "email"=$u.email ; "username"=$u.username ; "enabled"=$u.enabled ; "requiredActions"=$u.requiredActions} )| Out-Null
    }
    return $usersList
}

# Returns a user pbject, or fails
function GetKeyCloakUser($keycloakUri, $realmName, $accessToken, $username) {
    $kkUsers = GetKeycloakUsersList -keycloakUri $keycloakUri -realmName $realmName -accessToken $accessToken
    foreach ($kkUser in $kkUsers) {
        if ($kkUser.username -eq $username) {
            return $kkUser
        }
    }
    throw "User $username not found. Qutting."
}

function ListUserStatus($keycloakUri, $realmName, $keycloakUsername, $keycloakPassword) {
    BannerMessage -text "Current Users"
    $accessToken = Get-BearerToken -keycloakUri $keycloakUri -keycloakUsername $keycloakUsername -keycloakPassword $keycloakPassword
    $kkUsers = GetKeycloakUsersList -keycloakUri $keycloakUri -realmName $realmName -accessToken $accessToken
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
function ResetUserPassword($keycloakUri, $realmName, $username, $keycloakUsername, $keycloakPassword, $resetToTemporaryPassword="true") {
    BannerMessage -text "Resetting Password for user $username"
    $accessToken = Get-BearerToken -keycloakUri $keycloakUri -keycloakUsername $keycloakUsername -keycloakPassword $keycloakPassword
    $resetToTemporaryPassword = ($resetToTemporaryPassword).tolower()
    $newUserPassword = RandomPWD
    $headers = GetHeaders -accessToken $accessToken
    $kkUser = GetKeyCloakUser -keycloakUri $keycloakUri -realmName $realmName -accessToken $accessToken -username $username
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

# PUT /{realm}/users/{id}
function DisableUser($keycloakUri, $realmName, $keycloakUsername, $keycloakPassword, $username) {
    BannerMessage -text "Disabling User $username"
    $accessToken = Get-BearerToken -keycloakUri $keycloakUri -keycloakUsername $keycloakUsername -keycloakPassword $keycloakPassword
    $headers = GetHeaders -accessToken $accessToken
    $kkUser = GetKeyCloakUser -keycloakUri $keycloakUri -realmName $realmName -accessToken $accessToken -username $username
    $keycloakRestURL = "$( $keycloakUri )admin/realms/$realmName/users/$( $kkUser.id )"
    $json = "{""enabled"" :""false""}"
    $response = Invoke-WebRequest $keycloakRestURL -Method Put  -Body ([System.Text.Encoding]::UTF8.GetBytes($json)) -Headers $headers -ContentType "application/json"
    if ($response.StatusCode -eq 204) {
        Write-Host "User $($username) now DISABLED"
    } else {
        $($response.RawContent)
        throw "Disable failed for user '$($username)'"
    }
}
function EnableUser($keycloakUri, $realmName, $keycloakUsername, $keycloakPassword, $username) {
    BannerMessage -text "Enabling User $username"
    $accessToken = Get-BearerToken -keycloakUri $keycloakUri -keycloakUsername $keycloakUsername -keycloakPassword $keycloakPassword
    $headers = GetHeaders -accessToken $accessToken
    $kkUser = GetKeyCloakUser -keycloakUri $keycloakUri -realmName $realmName -accessToken $accessToken -username $username
    $keycloakRestURL = "$( $keycloakUri )admin/realms/$realmName/users/$( $kkUser.id )"
    $json = "{""enabled"" :""true""}"
    $response = Invoke-WebRequest $keycloakRestURL -Method Put  -Body ([System.Text.Encoding]::UTF8.GetBytes($json)) -Headers $headers -ContentType "application/json"
    if ($response.StatusCode -eq 204) {
        Write-Host "User $($username) now ENABLED"
    } else {
        $($response.RawContent)
        throw "Enable failed for user '$($username)'"
    }
}

#############################################################################################################
# Dot source the script to load the functions. Run a loginParams var. Uncomment what you want to test
<#

. ./ManageKeycloakUsers.ps1

$loginParams = @{
    "keycloakUri"      = 'http://nuc-linux-build:8080/auth/'
    "realmName"        = 'RiskIntegrity'
    "keycloakUsername" = 'admin'
    "keycloakPassword" = 'Password1!'
}

# Then you can run these

ListUserStatus @loginParams
ResetUserPassword @loginParams -username user1
DisableUser @loginParams -username user1
EnableUser @loginParams -username user1
ListUserStatus @loginParams

# TODO: CreateUser, DeleteUser
#>