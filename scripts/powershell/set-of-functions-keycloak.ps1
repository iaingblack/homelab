function Get-KeycloakAccessToken {
    param(
        [string]$KeycloakBaseUrl,
        [string]$ClientId,
        [string]$ClientSecret,
        [string]$Username,
        [string]$Password
    )

    $tokenUrl = "$KeycloakBaseUrl/protocol/openid-connect/token"
    $tokenData = @{
        grant_type    = "password"
        client_id     = $ClientId
        client_secret = $ClientSecret
        username      = $Username
        password      = $Password
    }

    $response = Invoke-RestMethod -Uri $tokenUrl -Method Post -ContentType "application/x-www-form-urlencoded" -Body $tokenData
    return $response.access_token
}

function Invoke-KeycloakAdminAPI {
    param (
        [string]$KeycloakURL,
        [string]$AdminUsername,
        [string]$AdminPassword,
        [string]$RequestMethod,
        [string]$ApiEndpoint,
        [hashtable]$Headers = @(),
        [hashtable]$Body = @()
    )

    try {
        # Get the authentication token
        $token = Get-KeycloakAuthToken -KeycloakURL $KeycloakURL -AdminUsername $AdminUsername -AdminPassword $AdminPassword
        $token
        if ($token) {
            # Construct the full API URL
            $fullUrl = Join-Path -Path $KeycloakURL -ChildPath $ApiEndpoint

            # Set default headers
            $defaultHeaders = @{
                "Authorization" = "Bearer $token"
                "Content-Type" = "application/json"
            }

            # Merge custom headers with default headers
            $allHeaders = $defaultHeaders + $Headers

            # Invoke the API request
            $response = Invoke-RestMethod -Uri $fullUrl -Method $RequestMethod -Headers $allHeaders -Body ($Body | ConvertTo-Json)

            return $response
        }
    }
    catch {
        Write-Host "An error occurred: $_"
        return $null
    }
}

function Get-KeycloakRealmUsersWithStatus {
    param (
        [string]$KeycloakURL,
        [string]$AdminUsername,
        [string]$AdminPassword,
        [string]$RealmName
    )

    $apiEndpoint = "users"
    $usersResponse = Invoke-KeycloakAdminAPI -KeycloakURL $KeycloakURL -AdminUsername $AdminUsername -AdminPassword $AdminPassword -RequestMethod "GET" -ApiEndpoint "/$RealmName/users"

    if ($usersResponse) {
        foreach ($user in $usersResponse) {
            $userId = $user.id
            $username = $user.username
            $enabled = $user.enabled
            $requiredActions = $user.requiredActions -join ', '

            Write-Host "User ID: $userId"
            Write-Host "Username: $username"
            Write-Host "Enabled: $($enabled -eq $true)"

            if ($requiredActions) {
                Write-Host "Pending Actions: $requiredActions"
            }

            Write-Host "------------------------"
        }
    } else {
        Write-Host "Failed to retrieve users in the realm."
    }
}

function Get-KeycloakRealmUsersWithStatusAndRoles {
    param (
        [string]$KeycloakURL,
        [string]$AdminUsername,
        [string]$AdminPassword,
        [string]$RealmName
    )

    $apiEndpoint = "users"

    $usersResponse = Invoke-KeycloakAdminAPI -KeycloakURL $KeycloakURL -AdminUsername $AdminUsername -AdminPassword $AdminPassword -RequestMethod "GET" -ApiEndpoint "$apiEndpoint?realm=$RealmName"

    if ($usersResponse) {
        foreach ($user in $usersResponse) {
            $userId = $user.id
            $username = $user.username
            $enabled = $user.enabled
            $requiredActions = $user.requiredActions -join ', '

            # Get user's roles
            $userRolesResponse = Invoke-KeycloakAdminAPI -KeycloakURL $KeycloakURL -AdminUsername $AdminUsername -AdminPassword $AdminPassword -RequestMethod "GET" -ApiEndpoint "users/$userId/role-mappings/realm"
            $userRoles = $userRolesResponse | ForEach-Object { $_.name }

            Write-Host "User ID: $userId"
            Write-Host "Username: $username"
            Write-Host "Enabled: $($enabled -eq $true)"

            if ($requiredActions) {
                Write-Host "Pending Actions: $requiredActions"
            }

            if ($userRoles) {
                Write-Host "Roles: $($userRoles -join ', ')"
            }

            Write-Host "------------------------"
        }
    } else {
        Write-Host "Failed to retrieve users in the realm."
    }
}

function Create-KeycloakUser {
    param (
        [string]$KeycloakURL,
        [string]$AdminUsername,
        [string]$AdminPassword,
        [string]$RealmName,
        [string]$Username,
        [string]$Email,
        [string]$Password,
        [bool]$Enabled = $true
    )

    $apiEndpoint = "users"
    $userData = @{
        "username" = $Username
        "email" = $Email
        "enabled" = $Enabled
        "credentials" = @(
            @{
                "value" = $Password
                "type" = "password"
            }
        )
    }

    $response = Invoke-KeycloakAdminAPI -KeycloakURL $KeycloakURL -AdminUsername $AdminUsername -AdminPassword $AdminPassword -RequestMethod "POST" -ApiEndpoint $apiEndpoint -Body $userData

    if ($response -and $response.status_code -eq 201) {
        Write-Host "User '$Username' has been created."
    } else {
        Write-Host "Failed to create user. Status code: $($response.status_code)"
    }
}

function Disable-KeycloakUser {
    param (
        [string]$KeycloakURL,
        [string]$AdminUsername,
        [string]$AdminPassword,
        [string]$RealmName,
        [string]$UsernameToDisable,
        [bool]$DisableUser = $true
    )

    $apiEndpoint = "users"
    $findUserResponse = Invoke-KeycloakAdminAPI -KeycloakURL $KeycloakURL -AdminUsername $AdminUsername -AdminPassword $AdminPassword -RequestMethod "GET" -ApiEndpoint "$apiEndpoint?username=$UsernameToDisable"

    if ($findUserResponse -and $findUserResponse.Count -eq 1) {
        $user = $findUserResponse[0]
        $userData = @{
            "enabled" = !$DisableUser
        }

        $response = Invoke-KeycloakAdminAPI -KeycloakURL $KeycloakURL -AdminUsername $AdminUsername -AdminPassword $AdminPassword -RequestMethod "PUT" -ApiEndpoint "users/$($user.id)" -Body $userData

        if ($response -and $response.status_code -eq 204) {
            $action = if ($DisableUser) { "disabled" } else { "enabled" }
            Write-Host "User '$UsernameToDisable' has been $action."
        } else {
            Write-Host "Failed to $action user. Status code: $($response.status_code)"
        }
    } else {
        Write-Host "User '$UsernameToDisable' not found."
    }
}

function Delete-KeycloakUser {
    param (
        [string]$KeycloakURL,
        [string]$AdminUsername,
        [string]$AdminPassword,
        [string]$RealmName,
        [string]$UsernameToDelete
    )

    $apiEndpoint = "users"
    $findUserResponse = Invoke-KeycloakAdminAPI -KeycloakURL $KeycloakURL -AdminUsername $AdminUsername -AdminPassword $AdminPassword -RequestMethod "GET" -ApiEndpoint "$apiEndpoint?username=$UsernameToDelete"

    if ($findUserResponse -and $findUserResponse.Count -eq 1) {
        $user = $findUserResponse[0]
        $response = Invoke-KeycloakAdminAPI -KeycloakURL $KeycloakURL -AdminUsername $AdminUsername -AdminPassword $AdminPassword -RequestMethod "DELETE" -ApiEndpoint "users/$($user.id)"

        if ($response -and $response.status_code -eq 204) {
            Write-Host "User '$UsernameToDelete' has been deleted."
        } else {
            Write-Host "Failed to delete user. Status code: $($response.status_code)"
        }
    } else {
        Write-Host "User '$UsernameToDelete' not found."
    }
}

function Add-KeycloakUserRole {
    param (
        [string]$KeycloakURL,
        [string]$AdminUsername,
        [string]$AdminPassword,
        [string]$RealmName,
        [string]$UsernameToAddRole,
        [string]$RoleNameToAdd
    )

    $apiEndpoint = "users"
    $findUserResponse = Invoke-KeycloakAdminAPI -KeycloakURL $KeycloakURL -AdminUsername $AdminUsername -AdminPassword $AdminPassword -RequestMethod "GET" -ApiEndpoint "$apiEndpoint?username=$UsernameToAddRole"

    if ($findUserResponse -and $findUserResponse.Count -eq 1) {
        $user = $findUserResponse[0]

        # Get the user's ID
        $userId = $user.id

        # Find the role by name
        $findRoleResponse = Invoke-KeycloakAdminAPI -KeycloakURL $KeycloakURL -AdminUsername $AdminUsername -AdminPassword $AdminPassword -RequestMethod "GET" -ApiEndpoint "roles?name=$RoleNameToAdd"

        if ($findRoleResponse -and $findRoleResponse.Count -eq 1) {
            $role = $findRoleResponse[0]

            # Get the role's ID
            $roleId = $role.id

            # Add the role to the user
            $headers = @{
                "Authorization" = "Bearer $token"
            }

            $body = @{
                "realm" = $RealmName
                "userId" = $userId
                "roles" = @($roleId)
            }

            $response = Invoke-KeycloakAdminAPI -KeycloakURL $KeycloakURL -AdminUsername $AdminUsername -AdminPassword $AdminPassword -RequestMethod "POST" -ApiEndpoint "users/$userId/role-mappings/realm" -Headers $headers -Body $body

            if ($response -and $response.status_code -eq 204) {
                Write-Host "User '$UsernameToAddRole' has been assigned the role '$RoleNameToAdd'."
            } else {
                Write-Host "Failed to assign role to user. Status code: $($response.status_code)"
            }
        } else {
            Write-Host "Role '$RoleNameToAdd' not found."
        }
    } else {
        Write-Host "User '$UsernameToAddRole' not found."
    }
}

function Remove-KeycloakUserRole {
    param (
        [string]$KeycloakURL,
        [string]$AdminUsername,
        [string]$AdminPassword,
        [string]$RealmName,
        [string]$UsernameToRemoveRole,
        [string]$RoleNameToRemove
    )

    $apiEndpoint = "users"
    $findUserResponse = Invoke-KeycloakAdminAPI -KeycloakURL $KeycloakURL -AdminUsername $AdminUsername -AdminPassword $AdminPassword -RequestMethod "GET" -ApiEndpoint "$apiEndpoint?username=$UsernameToRemoveRole"

    if ($findUserResponse -and $findUserResponse.Count -eq 1) {
        $user = $findUserResponse[0]

        # Get the user's ID
        $userId = $user.id

        # Find the role by name
        $findRoleResponse = Invoke-KeycloakAdminAPI -KeycloakURL $KeycloakURL -AdminUsername $AdminUsername -AdminPassword $AdminPassword -RequestMethod "GET" -ApiEndpoint "roles?name=$RoleNameToRemove"

        if ($findRoleResponse -and $findRoleResponse.Count -eq 1) {
            $role = $findRoleResponse[0]

            # Get the role's ID
            $roleId = $role.id

            # Remove the role from the user
            $headers = @{
                "Authorization" = "Bearer $token"
            }

            $response = Invoke-KeycloakAdminAPI -KeycloakURL $KeycloakURL -AdminUsername $AdminUsername -AdminPassword $AdminPassword -RequestMethod "DELETE" -ApiEndpoint "users/$userId/role-mappings/realm/$roleId" -Headers $headers

            if ($response -and $response.status_code -eq 204) {
                Write-Host "Role '$RoleNameToRemove' has been removed from user '$UsernameToRemoveRole'."
            } else {
                Write-Host "Failed to remove role from user. Status code: $($response.status_code)"
            }
        } else {
            Write-Host "Role '$RoleNameToRemove' not found."
        }
    } else {
        Write-Host "User '$UsernameToRemoveRole' not found."
    }
}

function Add-KeycloakUser {
    param (
        [string]$KeycloakURL,
        [string]$AdminUsername,
        [string]$AdminPassword,
        [string]$RealmName,
        [string]$Username,
        [string]$Email,
        [string]$Password,
        [bool]$Enabled = $true
    )

    $apiEndpoint = "users"
    $userData = @{
        "username" = $Username
        "email" = $Email
        "enabled" = $Enabled
        "credentials" = @(
            @{
                "value" = $Password
                "type" = "password"
            }
        )
    }

    $response = Invoke-KeycloakAdminAPI -KeycloakURL $KeycloakURL -AdminUsername $AdminUsername -AdminPassword $AdminPassword -RequestMethod "POST" -ApiEndpoint $apiEndpoint -Body $userData

    if ($response -and $response.status_code -eq 201) {
        Write-Host "User '$Username' has been created."
    } else {
        Write-Host "Failed to create user. Status code: $($response.status_code)"
    }
}

function Reset-KeycloakUserPassword {
    param (
        [string]$KeycloakURL,
        [string]$AdminUsername,
        [string]$AdminPassword,
        [string]$RealmName,
        [string]$UsernameToReset,
        [string]$NewPassword
    )

    $apiEndpoint = "users"
    $findUserResponse = Invoke-KeycloakAdminAPI -KeycloakURL $KeycloakURL -AdminUsername $AdminUsername -AdminPassword $AdminPassword -RequestMethod "GET" -ApiEndpoint "$apiEndpoint?username=$UsernameToReset"

    if ($findUserResponse -and $findUserResponse.Count -eq 1) {
        $user = $findUserResponse[0]

        # Get the user's ID
        $userId = $user.id

        # Reset the user's password
        $headers = @{
            "Authorization" = "Bearer $token"
        }

        $body = @{
            "type" = "password"
            "temporary" = $false
            "value" = $NewPassword
        }

        $response = Invoke-KeycloakAdminAPI -KeycloakURL $KeycloakURL -AdminUsername $AdminUsername -AdminPassword $AdminPassword -RequestMethod "PUT" -ApiEndpoint "users/$userId/reset-password" -Headers $headers -Body $body

        if ($response -and $response.status_code -eq 204) {
            Write-Host "Password for user '$UsernameToReset' has been reset."
        } else {
            Write-Host "Failed to reset password. Status code: $($response.status_code)"
        }
    } else {
        Write-Host "User '$UsernameToReset' not found."
    }
}

# ------------------------
#. .\keycloak_operations.ps1
# ------------------------
# $keycloak_url = "http://nuc-linux-build:8080/auth/"
# $adminUsername = "keycloak"
# $adminPassword = "Password1!"
# $realmName = "RiskIntegrity"
# ------------------------
# . ./set-of-functions-keycloak.ps1; Get-KeycloakRealmUsersWithStatus         -KeycloakURL $keycloak_url -AdminUsername $adminUsername -AdminPassword $adminPassword -RealmName $realmName
# . ./set-of-functions-keycloak.ps1; Get-KeycloakRealmUsersWithStatusAndRoles -KeycloakURL $keycloak_url -AdminUsername $adminUsername -AdminPassword $adminPassword -RealmName $realmName
# . ./set-of-functions-keycloak.ps1; Add-KeycloakUser                         -KeycloakURL $keycloak_url -AdminUsername $adminUsername -AdminPassword $adminPassword -RealmName $realmName -Username "new_user" -Email "new_user@example.com" -Password "user-password"
# . ./set-of-functions-keycloak.ps1; Create-KeycloakUser                      -KeycloakURL $keycloak_url -AdminUsername $adminUsername -AdminPassword $adminPassword -RealmName $realmName-Username "new_user" -Email "new_user@example.com" -Password "user-password"
# . ./set-of-functions-keycloak.ps1; Delete-KeycloakUser                      -KeycloakURL $keycloak_url -AdminUsername $adminUsername -AdminPassword $adminPassword -RealmName $realmName -UsernameToDelete "username-to-delete"
# . ./set-of-functions-keycloak.ps1; Disable-KeycloakUser                     -KeycloakURL $keycloak_url -AdminUsername $adminUsername -AdminPassword $adminPassword -RealmName $realmName -UsernameToDisable "username-to-disable" -DisableUser $false
# . ./set-of-functions-keycloak.ps1; Add-KeycloakUserRole                     -KeycloakURL $keycloak_url -AdminUsername $adminUsername -AdminPassword $adminPassword -RealmName $realmName -UsernameToAddRole "username-to-add-role" -RoleNameToAdd "desired-role-name"
# . ./set-of-functions-keycloak.ps1; Remove-KeycloakUserRole                  -KeycloakURL $keycloak_url -AdminUsername $adminUsername -AdminPassword $adminPassword -RealmName $realmName -UsernameToRemoveRole "username-to-remove-role" -RoleNameToRemove "desired-role-name"
# . ./set-of-functions-keycloak.ps1; Reset-KeycloakUserPassword               -KeycloakURL $keycloak_url -AdminUsername $adminUsername -AdminPassword $adminPassword -RealmName $realmName -UsernameToReset "username-to-reset" -NewPassword "new-password"
