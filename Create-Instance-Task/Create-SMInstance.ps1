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
    [string]$InstanceName     = Get-VstsInput -Name InstanceName -Require
    [String]$SMVersion        = Get-VstsInput -Name SMVersion -Require
    [String]$DataBaseServer   = Get-VstsInput -Name DataBaseServer -Require
    [String]$DataBase         = Get-VstsInput -Name DataBase -Require
    [String]$DataBaseUser     = Get-VstsInput -Name DataBaseUser
    [String]$DataBasePassword = Get-VstsInput -Name DataBasePassword
    [String]$LicenseServer    = Get-VstsInput -Name LicenseServer
    [boolean]$TrustedConnection = Get-VstsInput -Name TrustedConnection -AsBool

    if($null -eq $InstanceName){
        Write-VstsTaskError "Instance not specified"
    }
    if($null -eq $SMVersion){
        Write-VstsTaskError "SampleManager Version not specified"
    }
    if($null -eq $DataBaseServer){
        Write-VstsTaskError "DataBaseServer not specified"
    }
    if($null -eq $DataBase){
        Write-VstsTaskError "DataBase not specified"
    }

    if($SMVersion -match '(?<major>12).(?<minor>[1-9]).(?<patch>[0-9])?'){
        $Major = $Matches.major
        $Minor = $Matches.minor
        $Patch = $Matches.patch
        if("0" -eq $Patch){
            $SMVersion = "$Major.$Minor"
        }

        if(Test-Path -Path $VersionRootKey){

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
            $cmdArgList = @(
                "-n", "$InstanceName",
                "-dbs", "$DataBaseServer",
                "-db", "$DataBase"
                "-ls", "$LicenseServer"
                "-ado", "$AdoConnectionString"
            )

            Write-VstsTaskDebug "Executing $builder";
            $result = & $builder $cmdArgList;
            Write-VstsTaskDebug "\t$result";

            if($LASTEXITCODE -eq 1)
            {
                Write-VstsTaskError "Instance was not builded properly => $result"
            }
        }
        else {
            Write-VstsTaskError "SampleManager not installed"
        }
    else {
        Write-VstsTaskError "Version $SMVersion is not valid"
    }

} finally {
	Trace-VstsLeavingInvocation $MyInvocation
}