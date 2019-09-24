

[CmdletBinding()]
param()

Trace-VstsEnteringInvocation $MyInvocation
Import-VstsLocStrings "$PSScriptRoot\task.json"

$RootKey = 'HKLM:SOFTWARE\Wow6432Node\LabSystems\SampleManager Server';

function Remove-Data {
    param (
        [string]$InstanceName,
        [string]$InstanceExeFolder
    )
    $builder = Join-Path $InstanceExeFolder 'convert_table.exe';
    $cmdArgList = @(
        "-instance", "$InstanceName"
        "-noconfirm"
        "-tables", "*"
        "-mode", "destroy"
    )

    Write-VstsTaskDebug "Executing $builder";
    $result = & $builder $cmdArgList
    Write-VstsTaskDebug "\t$result";

    if($LASTEXITCODE -eq 1)
    {
        Write-VstsTaskError "Could not delete Data in Database => $result"
    }    
}

function Remove-Services {
    param (
        [string]$InstanceName
    )
    Write-VstsTaskDebug "Removing Services for Instance $InstanceName"

    foreach ($instanceService in Get-Service *$InstanceName*) {
        $serviceName = $instanceService.Name;
        Write-VstsTaskDebug "Removing Service $serviceName"
        $service = Get-WmiObject -Class Win32_Service -Filter "Name='$serviceName'"
        if($null -ne $service){
            $service.StopService();
            $service.delete();
        }
        else {
            Write-VstsTaskError "Service $ServiceName was not found!!!"
        }        
    }   
}

try{
    [string]$InstanceName  = Get-VstsInput -Name InstanceName -Require
    [boolean]$DropData     = Get-VstsInput -Name DropData -Require -AsBool
    [boolean]$DropDataBase = Get-VstsInput -Name DropDataBase -Require -AsBool

    Write-VstsTaskDebug "Instance to delete: $InstanceName";
    Write-VstsTaskDebug "Dropping Database:  $DropData";

    Stop-Process -Name "SampleManager" -ErrorAction SilentlyContinue

    $InstanceRootKey = Join-Path $RootKey $InstanceName

    if(Test-Path -Path $InstanceRootKey)
    {
        $InstanceRootFolder = (Get-ItemProperty -Path $InstanceRootKey).'smp$root';
        $InstanceExeFolder = (Get-ItemProperty -Path $InstanceRootKey).'smp$programs';
        
        if ($DropData)
        {
            Remove-Data $InstanceName $InstanceExeFolder
        }

        Write-VstsTaskVerbose "Deleting Services"
        Remove-Services $InstanceName
        
        Write-VstsTaskVerbose "Deleting Instance Folder"
        Write-VstsTaskDebug "$InstanceRootFolder"
        Remove-Item $InstanceRootFolder -Force -Recurse

        Write-VstsTaskVerbose "Deleting Instance Registry Entries"
        Write-VstsTaskDebug "$InstanceRootKey"
        Remove-Item $RootKey -Force -Recurse
        
        if ($DropDataBase)
        {
            
        }
    }
} catch {

    Write-Verbose "Exception caught from task: $($_.Exception.ToString())"

    throw
} finally {
	Trace-VstsLeavingInvocation $MyInvocation
}