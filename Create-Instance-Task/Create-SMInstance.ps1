[CmdletBinding()]
param()

Trace-VstsEnteringInvocation $MyInvocation
Import-VstsLocStrings "$PSScriptRoot\task.json"

$RootKey = 'HKLM:SOFTWARE\Wow6432Node\LabSystems\';
$VersionRootKey = Join-Path $RootKey "SampleManager";
$AdoConnectionString = "INVALID";

# Template Connectionstrings
# Provider=SQLNCLI11;Server=SM-BUILD-SQL;Database=VGSM;User Id=VGSM;Password=VGSM;MARS Connection=true;
# Provider=SQLNCLI11;Server=SM-BUILD-SQL;Database=VGSM;Trusted_Connection=yes;MARS Connection=true;

try{
    $InstanceName     = Get-VstsInput -Name InstanceName -Require
    $SMVersion        = Get-VstsInput -Name SMVersion -Require
    $DataBaseServer   = Get-VstsInput -Name DataBaseServer -Require
    $DataBase         = Get-VstsInput -Name DataBase -Require
    $DataBaseUser     = Get-VstsInput -Name DataBaseUser
    $DataBasePassword = Get-VstsInput -Name DataBasePassword
    $LicenseServer    = Get-VstsInput -Name LicenseServer
    $TrustedConnection = Get-VstsInput -Name TrustedConnection

    $VersionRootFolder = (Get-ItemProperty -Path (Join-Path $VersionRootKey $SMVersion)).RootFolder
    $VersionExeFolder = Join-Path $VersionRootFolder "EXE"

    Write-VstsTaskDebug "Instancename: $InstanceName";
    Write-VstsTaskDebug "SampleManager Version: $SMVersion";
    Write-VstsTaskDebug "Root Folder for Version $SMVersion is $VersionRootFolder"
    Write-VstsTaskDebug "Exe Folder for Version $SMVersion is $VersionExeFolder"
    Write-VstsTaskDebug "Database Server: $DataBaseServer";
    Write-VstsTaskDebug "Database: $DataBase";
    if ($TrustedConnection) {
        $AdoConnectionString = "Provider=SQLNCLI11;Server=$DataBaseServer;Database=$DataBase;Trusted_Connection=yes;MARS Connection=true;"
    }
    else {
        $AdoConnectionString = "Provider=SQLNCLI11;Server=$DataBaseServer;Database=$DataBase;User Id=$DataBaseUser;Password=$DataBasePassword;MARS Connection=true"
    }
    Write-VstsTaskDebug "Using connectionstring: $AdoConnectionString";
    Write-VstsTaskDebug "Using Licenseserver: $LicenseServer";

    $builder = Join-Path $VersionExeFolder 'BuildInstance.exe';
    $result = .$builder -n $InstanceName -dbs $DataBaseServer -db $DataBase -ls $LicenseServer -ado $AdoConnectionString

    if($LASTEXITCODE -eq 1)
    {
        Write-VstsTaskError "Instance was not builded properly => $result"
    }

} finally {
	Trace-VstsLeavingInvocation $MyInvocation
}