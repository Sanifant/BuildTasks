[CmdletBinding()]
param()

. $PSScriptRoot\lib\Initialize-Test.ps1

Register-Mock Trace-VstsEnteringInvocation
Register-Mock Trace-VstsLeavingInvocation
Register-Mock Import-VstsLocStrings
Register-Mock Get-VstsInput { 'VGSM' } -- -Name InstanceName
Register-Mock Write-VstsTaskError

$actual = & $PSScriptRoot\..\Create-Instance-Task\Create-SMInstance.ps1
write-host $actual

Assert-WasCalled Write-VstsTaskError
