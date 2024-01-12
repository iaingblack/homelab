# Making it a set of functions makes it super portable and we can make many custom entry points instead of just one
# . ./set-of-functions-to-source.ps1
# Change-User-Password test Password1

# Octopus deploy is like this if you use a package as a source
#    cd $OctopusParameters["Octopus.Action.Package[homelab].ExtractedPath"]
#    . ./scripts/powershell/set-of-functions-to-source.ps1
#    Change-User-Password test Password1

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
