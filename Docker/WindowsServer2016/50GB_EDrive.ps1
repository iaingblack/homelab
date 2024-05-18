#NEEDS TOO MANY PREREQS
$vhdpath = "C:\VHDs\Test.vhdx"
$driveLetter = "E"
$vhdsize = 50GB
New-VHD -Path $vhdpath -Dynamic -SizeBytes $vhdsize 
 | Mount-VHD -Passthru 
 | Initialize-Disk -Passthru 
 | New-Partition -AssignDriveLetter -UseMaximumSize 
 | Format-Volume -FileSystem NTFS -Confirm:$false -Force

New-VHD -Path $vhdPath -SizeBytes $vhdSize -Dynamic 
Mount-VHD -Path $vhdPath
$disk = get-vhd -path $vhdPath
Initialize-Disk $disk.DiskNumber
$partition = New-Partition -AssignDriveLetter -UseMaximumSize -DiskNumber $disk.DiskNumber
$volume = Format-Volume -FileSystem NTFS -Confirm:$false -Force -Partition $partition

Add-PartitionAccessPath -DiskNumber 1 -PartitionNumber 2 -AccessPath F:

Dismount-VHD -Path $vhdPath
Add-VMHardDiskDrive -VMName $n -Path $vhdPath
