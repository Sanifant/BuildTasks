[CmdletBinding()]
param()

Trace-VstsEnteringInvocation $MyInvocation
Import-VstsLocStrings "$PSScriptRoot\Task.json"

$RootKey = 'HKLM:SOFTWARE\Wow6432Node\LabSystems\';
$VersionRootKey = Join-Path $RootKey "SampleManager";
$InstanceRootKey = Join-Path $RootKey "SampleManager Server";

try{
    $InstanceName     = Get-VstsInput -Name InstanceName -Require
    $SMVersion        = Get-VstsInput -Name SMVersion -Require
    $DataBaseServer   = Get-VstsInput -Name DataBaseServer -Require
    $DropData         = Get-VstsInput -Name DropData -Require

    Write-VstsTaskDebug $InstanceName;
    Write-VstsTaskDebug $DropData;

    Stop-Process -Name "SampleManager" -ErrorAction SilentlyContinue

    if(Test-Path -Path (Join-Path $InstanceRootKey $InstanceName))
    {
        $InstanceRootKey = Join-Path $InstanceRootKey $InstanceName
        $InstanceRootFolder = (Get-ItemProperty -Path $InstanceRootKey).'smp$root';

        $VersionRootFolder = (Get-ItemProperty -Path (Join-Path $VersionRootKey $SMVersion)).RootFolder
        Write-VstsTaskVerbose "Root Folder for Version $SMVersion is $VersionRootFolder"
        $VersionExeFolder = Join-Path $VersionRootFolder "EXE"
        Write-VstsTaskDebug "Exe Folder for Version $SMVersion is $VersionExeFolder"
        
        if ($DropData)
        {
            $builder = Join-Path $VersionExeFolder 'convert_table.exe';
            $result = .$builder -instance $InstanceName -noconfirm -tables * -mode destroy
            if($LASTEXITCODE -eq 1)
            {
                Write-VstsTaskError "Could not delete Data in Database => $result"
            }
        }

        
        Write-VstsTaskVerbose "Deleting Services"
        Remove-Service smplock$InstanceName
        Remove-Service smp$InstanceName
        Remove-Service smdaemon$InstanceName
        Remove-Service smptq$InstanceName
        Remove-Service smpwcf$InstanceName
        Remove-Service smpbatch$InstanceName_$backtest
        Remove-Service smpbatch$InstanceName_$jobwkshbk
        Remove-Service smpbatch$InstanceName_$rslt_pipe
        
        Write-VstsTaskVerbose "Deleting Instance Folders"
        Remove-Item $InstanceRootFolder -Force

        Write-VstsTaskVerbose "Deleting Instance Registry Entries"
        Remove-Item $InstanceRootKey -Force
    }
} finally {
	Trace-VstsLeavingInvocation $MyInvocation
}