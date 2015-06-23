# Load the custom functions
. ./Functions.ps1
. ./report.ps1

# Connect to protected site VC & SRM
$creds = Get-Credential
$vca = Connect-VIServer <VC_IP> -Credential $creds
$srma = Connect-SrmServer -Server $vca -Credential $creds -RemoteCredential $creds

# Output Current SRM Configuration Report
Get-SrmConfigReport

# get recovery plan
$rp = Get-RecoveryPlan "rp1"


forEach ( $vmlist in Get-ProtectedVM) {

$pvm = $vmlist 


# get protected VM

#$pvm =  Get-ProtectedVM | Select -First 1

write-host "Printing pvm $pvm"

# view recovery settings
$rs = $pvm | Get-RecoverySettings -RecoveryPlan $rp

# update recovery priority
$rs.RecoveryPriority = "highest"
$rs.powerOnTimeoutSeconds = "2000"


# create new command callout
$srmCmd = New-SrmCommand -Command 'ping -c 250 localhost' -Description 'Run standard linux failover script' -RunInRecoveredVm

# add command as post recovery command callout
Add-PostRecoverySrmCommand -RecoverySettings $rs -SrmCommand $srmCmd

# update the recovery settings on the SRM server
Set-RecoverySettings -ProtectedVm $pvm -RecoveryPlan $rp -RecoverySettings $rs


}
