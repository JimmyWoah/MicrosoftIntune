#0x5944 deploy all needed certificates and update to the PCA2023 signed Boot Manager
#It requires reboot!

$hivePath  = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot\'
$keyName  = 'AvailableUpdates'
$keyValue = 0x5944

if (!(Test-Path $hivePath)) {New-Item -Path $hivePath -Force}
New-ItemProperty -Path $hivePath -Name $keyName -PropertyType DWord -Value $keyValue -Force