function Create-EICAzureDiskOnVM
{
	<#
    .SYNOPSIS
    Adds a disk to a VM and formats with desired drive letter

    .DESCRIPTION
    Just makes things easier

    .EXAMPLE
    Create-EICAzureDiskOnVM -ResourceGroupName 'MyRG' -VMName 'MyVMName' -SizeInGBs 50 -DriveLetter 'E' -Label 'Data' -StorageAccountType "Standard_LRS" -vmCred $vmCred

    #>
	
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $True)]
		[string]$ResourceGroupName,
		[Parameter(Mandatory = $True)]
		[string]$vmFQDN,
		[ValidateRange(1, 2048)]
		[Parameter(Mandatory = $True)]
		[int]$SizeInGBs,
		#[ValidatePattern({ ^[e-yE-Y]$ })]
		[Parameter(Mandatory = $True)]
		[string]$DriveLetter,
		[Parameter(Mandatory = $True)]
		[System.Management.Automation.PSCredential]$vmCred,
		[Parameter(Mandatory = $False)]
		[string]$DriveLabel,
		[ValidateSet("Standard_LRS", "Premium_LRS", "StandardSSD_LRS")]
		[Parameter(Mandatory = $False)]
		[string]$StorageAccountType = "Standard_LRS"
	)
	
	$initaliseDisksScript = {
		param ($DriveLetter,
			$DriveLabel)
		$disks = Get-Disk | Where-Object partitionstyle -eq "raw" | Sort-Object number
		$firstPass = $True
		if ($null -eq $disks)
		{
			Write-Output "No blank disks found to initialise"
		}
		else
		{
			Write-Output "Initialising $disks Disks"
			# This can do multiple disks at once, keep the logic in case useful later
			foreach ($disk in $disks)
			{
				#First pass try to find if a CD drive exists as E:. If it does move it out the way
				if ($firstPass)
				{
					$drive = Get-WmiObject win32_volume -filter 'DriveLetter = "E:"'
					if ($drive.DriveType -eq "5")
					{
						Write-Output "E: exists as a CD drive. Changing it to a Z:"
						$drive.DriveLetter = "Z:"
						$drive.Put()
					}
				}
				$firstPass = $false
				Write-Output "Trying to create a disk with letter $driveLetter"
				$drive = Get-WmiObject win32_volume -filter "DriveLetter = ""$($driveLetter):"""
				# Drive letter does not exist already, create and map to it
				if ($null -eq $drive)
				{
					$disk |
					Initialize-Disk -PartitionStyle MBR -PassThru |
					New-Partition -UseMaximumSize -DriveLetter $driveLetter |
					Format-Volume -FileSystem NTFS -NewFileSystemLabel $DriveLabel -Confirm:$false -Force
				}
				else
				{
					Write-Output "Drive letter $driveLetter already exists. Going to next letter to map disk"
					$driveLetter = $driveletter.ToCharArray() | ForEach-Object{ [char]([int]($_) + 1) }
					if ($driveLetter -eq "z")
					{
						Write-Output "Couldnt find a drive letter. Quitting."
						exit 1
					}
				}
			}
		}
	}
	
	$vmName = $($vmFQDN.split('.')[0])
	# Data disks account name has to be unique so this part if a bit awkward. Annoyingly StandardLRS and not Standard_LRS is used in the command so remove the '_'
	# Not needed now. Storage accounttype expects teh underscore there
	$diskStorageAccountType = $storageAccountType
	# -replace '_', ''re

	Write-Output "Creating VM Data Disk Storage Account of type $diskStorageAccountType"
	
	# Just give an empty dosl label paremeter a generic name
	if ($null -eq $DriveLabel)
	{
		$DriveLabel = "$($DriveLetter)_Drive"
	}
	$vm = Get-AzureRmVM -ResourceGroupName $resourceGroupName -Name $VMName
	# The LUNs start at 0, so count how many disks we have attached and that is our next Lun Nnumber, simple! Doesnt seem to be a way to get LUNs so doing this.
	$vmLunNumber = $vm.StorageProfile.DataDisks.Count
	$diskName = "$($VMName)_Disk_$($DriveLabel)_$($vmLunNumber)"
	Output-EICVerboseMessage "Create-EICAzureDiskOnVM - Adding $($SizeInGBs)GB disk as $($DriveLetter): to VM $VMName with label $DriveLabel and type $($diskStorageAccountType). Disk will be called $diskName"
	Output-EICVerboseMessage "Create-EICAzureDiskOnVM - $VMName - Creating New-AzureRmDiskConfig -AccountType $diskStorageAccountType -Location $($vm.location) -OsType Windows -CreateOption Empty -DiskSizeGB $SizeInGBs"
	$diskConfig = New-AzureRmDiskConfig -AccountType $diskStorageAccountType -Location $($vm.location) -OsType Windows -CreateOption Empty -DiskSizeGB $SizeInGBs
	Output-EICVerboseMessage "Create-EICAzureDiskOnVM - $VMName - Creating New-AzureRmDisk -DiskName '$($VMName)_disk_$($vmLunNumber)' -Disk $diskConfig -ResourceGroupName $resourceGroupName"
	$disk = New-AzureRmDisk -DiskName $diskName -Disk $diskConfig -ResourceGroupName $resourceGroupName
	Output-EICVerboseMessage "Create-EICAzureDiskOnVM - $VMName - Adding Add-AzureRmVMDataDisk -VM $vm -Name '$($VMName)_disk_$($vmLunNumber)' -CreateOption Attach -ManagedDiskId $($disk.Id) -Lun ($diskNum-1)"
	Add-AzureRmVMDataDisk -VM $vm -Name $diskName -CreateOption Attach -ManagedDiskId $disk.Id -Lun $vmLunNumber
	Output-EICVerboseMessage "Create-EICAzureDiskOnVM - $VMName - Update-AzureRmVM -VM $vm -ResourceGroupName $resourceGroupName"
	Update-AzureRmVM -VM $vm -ResourceGroupName $resourceGroupName
	
	# Only do this if VM is running and we can connect to it
	if (Test-EICAzureVMIsRunning -ResourceGroupName $ResourceGroupName -VMName $vmName)
	{
		# Only do this if VM is running and we can connect to it. We need Azure VM name initially, not FQDN
		$scriptArgs = @($DriveLetter, $DriveLabel)
		try
		{
			Output-EICVerboseMessage "VM is On. Initialising Disk $diskName on VM $vmFQDN now"
			Invoke-Command -ComputerName $vmFQDN -Credential $vmCred -SessionOption (New-PsSessionOption -SkipCACheck -SkipCNCheck) -Scriptblock $initaliseDisksScript -ArgumentList $scriptArgs -ErrorAction Stop
		}
		catch
		{
			Output-EICVerboseMessage "Execute-EICScriptOnRemoteHost - Failed to execute file. Error below. Exiting"
			$_.Exception
			exit 1
		}
	}
	else
	{
		Output-EICVerboseMessage "VM $vmName is Off. Skipping Disk OS Initialisation"
	}
}