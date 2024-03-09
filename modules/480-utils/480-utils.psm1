function 480connect(){
$config = Get-Content -Path "config.json" | ConvertFrom-Json
$vcenter = $config.vCenterServer

# Use the vSphere address from the configuration

        # Connect to vCenter server
Connect-VIServer -Server $vcenter -ErrorAction Stop
}
function 480banner(){
    $banner = "WELCOME TO RYANMs EZPZ VM cloner"
    
    Write-host $banner
    Write-Host "-------------------------"
}

function NetworkAdapt {
    Write-Host "Available virtual machines:"
    Write-Host "-------------------------"
    Get-VM | Select-Object -ExpandProperty Name
    $vmName = Read-Host "Enter the VM you'd like to set the network adapter of:"
    $vm = Get-VM -Name $vmName -ErrorAction Stop

    Write-Host "Interfaces available on chosen VM:"
    Write-Host "-------------------------"
    Get-networkadapter  $vm | Select-Object -ExpandProperty Name
    $interfaceName = Read-Host "Which interface would you like to set network of:"
    $interface = Get-networkadapter $vm -Name $interfaceName -ErrorAction Stop

    Write-Host "Networks:"
    Write-Host "-------------------------"
    Get-virtualnetwork | Select-Object -ExpandProperty Name
    $networkName = Read-Host "Enter the network you'd like to assign to the chosen interface:"
    $network = Get-virtualnetwork -Name $networkName -ErrorAction Stop

    Set-NetworkAdapter -NetworkAdapter $interface -Networkname $network

    Write-Host "Adapter has been set"
}


#create new Vswitch//portgroup
function New-Network() {
$config = Get-Content -Path "config.json" | ConvertFrom-Json
$vcenter = $config.vSphereAddress
$switchname = Read-Host "Enter the name you would like to name your virtual switch:"
$virtualswitch = New-VirtualSwitch -VMHOST $vcenter -Name $switchname

$portgroupname = Read-Host "Enter the name of your new port group:"
$switchgroup = New-VirtualPortGroup -VirtualSwitch $virtualswitch -Name $portgroupname

Get-virtualswitch | Select-Object -ExpandProperty Name

}

 # Prompt user to power on the new virtual machine
function powervm() {
    $config = Get-Content -Path "config.json" | ConvertFrom-Json
  
    Write-Host "Available virtual machines:"
    Write-Host "-------------------------"
    Get-VM | Select-Object -ExpandProperty Name

    $vmName = Read-Host "Enter the VM youd like to poweron or shut down:"
    $vm = Get-VM -Name $vmName -ErrorAction Stop

    $powerOn = Read-Host "Do you want to power on the new virtual machine or stop it? (start or stop)"
 if ($powerOn -eq "start") {
     Start-VM -VM $vm -ErrorAction Stop

}
if ($powerOn -eq "stop") {
    Stop-VM -VM $vm -ErrorAction Stop

}
}

#Utilized chatgpt for the ip variable, specifically the where-object \d+\.\d+\.\ part, i understand how it works
function Get-IP() {

    $config = Get-Content -Path "config.json" | ConvertFrom-Json
    Write-Host "Available virtual machines:"
    Write-Host "-------------------------"
    Get-VM | Select-Object -ExpandProperty Name

    $vmName = Read-Host "Enter the VM youd like to get IP/MAC of:"
    $vm = Get-VM -Name $vmName -ErrorAction Stop

    Get-Networkadapter -VM $vm | Select-Object -ExpandProperty MacAddress
    $guest = $vm | Get-VMGuest
    $ip = $guest.ipaddress | Where-object {$_ -match '\d+\.\d+\.\d+\.\d+'}  #d+ = digit, \.\ is syntax from the ipv4
    Write-host $ip
    write-host $vm 
}




function 480cloner() {
    try {
        # Read configuration from JSON file
        $config = Get-Content -Path "config.json" | ConvertFrom-Json

        # Use the vCenter server name from the configuration
        $vcenter = $config.vCenterServer

        # Use the vSphere address from the configuration
        $vSphereAddress = $config.vSphereAddress

        # Connect to vCenter server
        Connect-VIServer -Server $vcenter -ErrorAction Stop

        # Display available virtual machines for user reference
        Write-Host "Available virtual machines:"
        Write-Host "-------------------------"
        Get-VM | Select-Object -ExpandProperty Name

        # Prompt user for virtual machine name
        $vmName = Read-Host "Enter the virtual machine name you would like to create a clone of:"

        # Get virtual machine by name
        $vm = Get-VM -Name $vmName -ErrorAction Stop

        # Use the snapshot name from the configuration
        $snapshotName = $config.snapshotName

        # Get snapshot by name
        $snapshot = Get-Snapshot -VM $vm -Name $snapshotName -ErrorAction Stop

        # Prompt user for VMHost name or IP address
        $vmhostName = $config.vSphereAddress
        # Get VMHost by name or IP address
        $vmhost = Get-VMHost -Name $vmhostName -ErrorAction Stop

        # Display available datastores for user reference
        Write-Host "Available datastores:"
        Write-Host "-------------------------"
        Get-Datastore | Select-Object -ExpandProperty Name

        # Prompt user for datastore name
        $datastoreName = Read-Host "Enter the datastore name"

        # Get datastore by name
        $ds = Get-Datastore -Name $datastoreName -ErrorAction Stop

        # Generate linked clone name
        $linkedClone = "{0}.linked" -f $vm.Name

        # Create linked clone virtual machine
        $linkedvm = New-VM -LinkedClone -Name $linkedClone -VM $vm -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $ds -ErrorAction Stop

        # Create new virtual machine from linked clone
        $newvmName = Read-Host "Enter the name for the new virtual machine"
        $newvm = New-VM -Name $newvmName -VM $linkedvm -VMHost $vmhost -Datastore $ds -ErrorAction Stop

        # Create snapshot for the new virtual machine
        $newvm | New-Snapshot -Name $snapshotName -ErrorAction Stop

        # Prompt user whether to remove the linked clone
        $removeLinkedClone = Read-Host "Do you want to remove the linked clone? (yes or no)"
        if ($removeLinkedClone -eq "yes") {
            $linkedvm | Remove-VM -ErrorAction Stop
        }
    } catch {
        # Display error message and stop execution
        Write-Error "An error occurred: $_"
        exit 1
    }
}



