$vcenter = "vcenter.ryan.local";
Connect-VIServer -Server $vcenter;

$vm = Get-vm -Name xubuntu-wan;
$snapshot = Get-Snapshot -VM $vm -Name "Base";

$vmhost = Get-VMhost -Name "192.168.7.25";
$ds = Get-datastore -Name "datastore1";

$linkedClone = "{0}.linked" -f $vm.name;
$linkedvm = New-VM -LinkedClone -Name $linkedClone -vm $vm -ReferenceSnapshot $snapshot -Vmhost $vmhost -Datastore $ds;

$newvm = New-VM -Name "xubuntu.base" -VM $linkedvm -Vmhost $vmhost -Datastore $ds;

$newvm | New-Snapshot -Name "Base";

$linkedvm | Remove-VM;
