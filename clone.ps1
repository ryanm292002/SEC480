# Prompt user for vCenter server name
$vcenter = Read-Host "Enter the vCenter server name (vcenter.ryan.local)"

# Connect to vCenter server
Connect-VIServer -Server $vcenter

# Display available virtual machines for user reference
Write-Host "Available virtual machines:"
Get-VM | Select-Object -ExpandProperty Name

# Prompt user for virtual machine name
$vmName = Read-Host "Enter the virtual machine name you would like to create clone of:"

# Get virtual machine by name
$vm = Get-VM -Name $vmName

# Prompt user for snapshot name
$snapshotName = Read-Host "Enter the snapshot name"

# Get snapshot by name
$snapshot = Get-Snapshot -VM $vm -Name $snapshotName

# Prompt user for VMHost name or IP address
$vmhostName = Read-Host "Enter the VSphere IP address"

# Get VMHost by name or IP address
$vmhost = Get-VMHost -Name $vmhostName

# Display available virtual machines for user reference
Write-Host "Available virtual machines:"
Get-Datastore | Select-Object -ExpandProperty Name

# Prompt user for datastore name
$datastoreName = Read-Host "Enter the datastore name"

# Get datastore by name
$ds = Get-Datastore -Name $datastoreName

# Generate linked clone name
$linkedClone = "{0}.linked" -f $vm.Name

# Create linked clone virtual machine
$linkedvm = New-VM -LinkedClone -Name $linkedClone -VM $vm -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $ds

# Create new virtual machine from linked clone
$newvmName = Read-Host "Enter the name for the new virtual machine"
$newvm = New-VM -Name $newvmName -VM $linkedvm -VMHost $vmhost -Datastore $ds

# Create snapshot for the new virtual machine
$newvm | New-Snapshot -Name "Base"

# Prompt user whether to remove the linked clone
$removeLinkedClone = Read-Host "Do you want to remove the linked clone? (yes or no)"
if ($removeLinkedClone -eq "yes") {
    $linkedvm | Remove-VM
}
