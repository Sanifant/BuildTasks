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
    $DataBase         = Get-VstsInput -Name DataBase -Require
    $DataBaseUser     = Get-VstsInput -Name DataBaseUser
    $DataBasePassword = Get-VstsInput -Name DataBasePassword
    $LicenseServer    = Get-VstsInput -Name LicenseServer

   Write-VstsTaskDebug $InstanceName;
   Write-VstsTaskDebug $VersionRootKey;
   Write-VstsTaskDebug $InstanceRootKey;
   Write-VstsTaskDebug $DataBaseServer;
   Write-VstsTaskDebug $DataBase;
   Write-VstsTaskDebug $DataBaseUser;
   Write-VstsTaskDebug $DataBasePassword;
   Write-VstsTaskDebug $LicenseServer;


   $VersionRootFolder = (Get-ItemProperty -Path (Join-Path $VersionRootKey $SMVersion)).RootFolder
   Write-VstsTaskDebug "Root Folder for Version $SMVersion is $VersionRootFolder"
   $VersionExeFolder = Join-Path $VersionRootFolder "EXE"
   Write-VstsTaskDebug "Exe Folder for Version $SMVersion is $VersionExeFolder"

    $builder = Join-Path $VersionExeFolder 'BuildInstance.exe';
    $result = .$builder -n $InstanceName -ls $LicenseServer -sqlserver $DataBaseServer -database $DataBase -databaseuser $DataBaseUser -databasepass $DataBasePassword

    if($LASTEXITCODE -eq 1)
    {
        Write-VstsTaskError "Instance was not builded properly => $result"
    }

} finally {
	Trace-VstsLeavingInvocation $MyInvocation
}