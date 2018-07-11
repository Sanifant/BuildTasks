Trace-VstsEnteringInvocation $MyInvocation
Import-VstsLocStrings "$PSScriptRoot\Task.json"

try{
    $InstanceName = Get-VstsInput -Name InstanceName -Require

} finally {
	Trace-VstsLeavingInvocation $MyInvocation
}