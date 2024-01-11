function Delete-User {
    param (
        [string]$username
    )
    Write-Host "Deleted User: $username"
}

function Add-User {
    param (
        [string]$username
    )
    Write-Host "Added User: $username"
}

function Change-User-Password {
    param (
        [string]$username,
        [string]$password
    )
    Write-Host "Amended User: $username   Password now: $password"
}

function Add-User-and-Password {
    param (
        [string]$username,
        [string]$password
    )
    Add-User $username
    Change-User-Password $username $password
}


# . ./set-of-functions-to-source.ps1
# add-user test
# delete-user test
# Change-User-Password test Password1