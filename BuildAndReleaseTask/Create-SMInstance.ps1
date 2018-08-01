[CmdletBinding()]
param()

Trace-VstsEnteringInvocation $MyInvocation
Import-VstsLocStrings "$PSScriptRoot\Task.json"

$RootKey = 'HKLM:SOFTWARE\Wow6432Node\LabSystems\';
$VersionRootKey = Join-Path $RootKey "SampleManager";
$InstanceRootKey = Join-Path $RootKey "SampleManager Server";

Function Update-Registry
{
    param(
        # Parameter help description
        [Parameter(Mandatory=$true)]
        [string]
        $RegistryPath,

        # VersionRootFolder
        [Parameter(Mandatory=$true)]
        [string]
        $VersionRootFolder,

        # Parameter help description
        [Parameter(Mandatory=$true)]
        [string]
        $InstanceRootFolder,

        # Parameter help description
        [Parameter(Mandatory=$true)]
        [string]
        $KeyName,

        # Parameter help description
        [Parameter(Mandatory=$true)]
        [string]
        $FolderName,

        # Parameter help description
        [Parameter(Mandatory=$false)]
        [switch]
        $DistributeFiles
    )

    $InstanceFolder = Join-Path $InstanceRootFolder $FolderName;
    $VersionFolder = Join-Path $VersionRootFolder $FolderName;
    $KeyValue = "$InstanceFolder;$VersionFolder";

    Write-VstsTaskDebug "Will update key $KeyName with value $KeyValue";

    IF(!(Test-Path $InstanceRootKey))
    {
        New-Item -Path $InstanceRootKey -Force | Out-Null
        New-ItemProperty -Path $InstanceRootKey -Name $KeyName -Value $KeyValue `
            -PropertyType String -Force | Out-Null
    }
    ELSE {
        New-ItemProperty -Path $InstanceRootKey -Name $KeyName -Value $KeyValue `
            -PropertyType String -Force | Out-Null
    }

    if(test-Path $InstanceFolder)
    {
        Remove-Item -Path $InstanceFolder -Force -Recurse -ErrorAction SilentlyContinue
    }

    if($DistributeFiles){
        Copy-Item -Path $VersionFolder -Destination $InstanceRootFolder -Recurse -Force
    }
    else {
        New-Item -ItemType Directory -Path $InstanceFolder
    }

    }


#SetInstanceValue(progress, "smp$root", rootPath);
#SetInstanceValue(progress, "smp$archivefiles", text + "\\archive");
#SetInstanceValue(progress, "smp$attachments", text + "\\attachment");
#SetInstanceValue(progress, "smp$comfiles", text + "\\command");
#SetInstanceValue(progress, "smp$listing", text + "\\lis");
#SetInstanceValue(progress, "smp$logfiles", text + "\\logfile");
#SetInstanceValue(progress, "smp$datastore", text + "\\datastore");
#SetInstanceValue(progress, "smp$programs", rootPath + "\\exe");
#SetInstanceValue(progress, "smp$resource", text + "\\resource");
#SetInstanceValue(progress, "smp$resultfiles", text + "\\resultfiles");
#SetInstanceValue(progress, "smp$sampletext", text + "\\sampletext");
#SetInstanceValue(progress, "smp$tabulator", text + "\\tabulator");
#SetInstanceValue(progress, "smp$textreports", text + "\\textreport");
#SetInstanceValue(progress, "smp$web_server_root", text + "\\web_server_root");
#SetInstanceValue(progress, "smp$worksheets", text + "\\worksheet");
#SetInstanceValue(progress, "smp$ado_cursor_location' 'SERVER");
#SetInstanceValue(progress, "smp$ado_cache_size' '800");
#SetInstanceValue(progress, "lock_daemon' 'smplock" + m_Instance.Name.ToLower());

try{
    $InstanceName = Get-VstsInput -Name InstanceName -Require
    $SMVersion = Get-VstsInput -Name SMVersion -Require

   Write-VstsTaskDebug $InstanceName;
   Write-VstsTaskDebug $VersionRootKey;
   Write-VstsTaskDebug $InstanceRootKey;

   $VersionRootFolder = (Get-ItemProperty -Path (Join-Path $VersionRootKey $SMVersion)).RootFolder
   Write-VstsTaskDebug "Root Folder for Version $SMVersion is $VersionRootFolder"

   Stop-Process -Name "SampleManager" -ErrorAction SilentlyContinue

   if(Test-Path -Path (Join-Path $InstanceRootKey $InstanceName))
   {
        $InstanceRootKey = Join-Path $InstanceRootKey $InstanceName
        $InstanceRootFolder = (Get-ItemProperty -Path $InstanceRootKey).'smp$root';
        $InstanceExeFolder = (Get-ItemProperty -Path $InstanceRootKey).'smp$programs';
        Write-VstsTaskDebug $InstanceExeFolder

        Write-VstsTaskVerbose "Stopping services";
        Stop-Service "smp$InstanceName";
        Stop-Service "smplock$InstanceName";
        Stop-Service "SMDaemon$InstanceName";
        Stop-Service "smptq$InstanceName";
        Stop-Service "smpWCF$InstanceName";
        Stop-Service "smpbatch$InstanceName*";

        Write-VstsTaskDebug "Root Folder for Instance $InstanceName is $InstanceRootFolder";
        Write-VstsTaskVerbose "Will update registry folder settings";

        Update-Registry $InstanceRootKey $VersionRootFolder $InstanceRootFolder 'smp$calculations' 'Calculation'
        Update-Registry $InstanceRootKey $VersionRootFolder $InstanceRootFolder 'smp$code' 'Code'
        Update-Registry $InstanceRootKey $VersionRootFolder $InstanceRootFolder 'smp$criteria' 'Criteria'
        Update-Registry $InstanceRootKey $VersionRootFolder $InstanceRootFolder 'smp$datafiles' 'Data'
        Update-Registry $InstanceRootKey $VersionRootFolder $InstanceRootFolder 'smp$forms' 'Form' -DistributeFiles
        Update-Registry $InstanceRootKey $VersionRootFolder $InstanceRootFolder 'smp$graphstyles' 'Graphstyles'
        Update-Registry $InstanceRootKey $VersionRootFolder $InstanceRootFolder 'smp$imprint' 'Imprint'
        Update-Registry $InstanceRootKey $VersionRootFolder $InstanceRootFolder 'smp$labels' 'Labels'
        Update-Registry $InstanceRootKey $VersionRootFolder $InstanceRootFolder 'smp$limit_calculations' 'Limit_calculation'
        Update-Registry $InstanceRootKey $VersionRootFolder $InstanceRootFolder 'smp$list_results' 'List_result'
        Update-Registry $InstanceRootKey $VersionRootFolder $InstanceRootFolder 'smp$messages' 'Message'
        Update-Registry $InstanceRootKey $VersionRootFolder $InstanceRootFolder 'smp$reports' 'Report'
        Update-Registry $InstanceRootKey $VersionRootFolder $InstanceRootFolder 'smp$sig_figs' 'Sig_figs'
        Update-Registry $InstanceRootKey $VersionRootFolder $InstanceRootFolder 'smp$sqlfiles' 'Sqlfile'
        Update-Registry $InstanceRootKey $VersionRootFolder $InstanceRootFolder 'smp$syntaxes' 'Syntax'
        Update-Registry $InstanceRootKey $VersionRootFolder $InstanceRootFolder 'smp$textfiles' 'Text'
        Update-Registry $InstanceRootKey $VersionRootFolder $InstanceRootFolder 'smp$userfiles' 'Userfiles'

        Write-VstsTaskVerbose "Distribute Exe Files"
        Remove-Item -Path $InstanceExeFolder -Force -Recurse -ErrorAction SilentlyContinue
        Copy-Item -Path (Join-Path $VersionRootFolder "Exe" ) -Destination $InstanceRootFolder -Recurse -Force

        Write-VstsTaskVerbose "Distribute Report Files"
        $InstanceReportFolder = (Get-ItemProperty -Path $InstanceRootKey).'smp$reports'.Split(';')[0];
        Copy-Item -Path (Join-Path $VersionRootFolder "report" ) -Destination $InstanceRootFolder -Recurse -Force

        Write-VstsTaskVerbose "Converting Table"
        $smp = Join-Path $InstanceExeFolder 'convert_table.exe';
        $result = .$smp -instance $InstanceName -tables * -noconfirm -mode newtable
        if($LASTEXITCODE -eq 1)
        {
            Write-VstsTaskError "Convert Table finished with error => $result"
        }

        Write-VstsTaskVerbose "Starting services";
        Start-Service "smp$InstanceName";
        Start-Service "smplock$InstanceName";
        Start-Service "SMDaemon$InstanceName";
        Start-Service "smptq$InstanceName";
        Start-Service "smpWCF$InstanceName";

        Write-VstsTaskVerbose "Compiling Reports"
        foreach ($report in Get-ChildItem (Join-Path $InstanceReportFolder '\*.rpf'))
        {
            Write-VstsTaskVerbose "Compiling Report $report"
            $smp = Join-Path $InstanceExeFolder 'compiler.exe';
            $result = .$smp -instance $InstanceName $report;
            if($LASTEXITCODE -eq 1)
            {
                Write-VstsTaskError "Report $report was not compiled successfully"
            }
        }

        Write-VstsTaskVerbose "Importing table data"
        $smp = Join-Path $InstanceExeFolder 'smp.exe';
        $result = .$smp -instance $InstanceName -batch -install
        if($LASTEXITCODE -eq 1)
        {
            Write-VstsTaskError "CSV $csv was not imported successfully"
        }

        Write-VstsTaskVerbose "Creating Messages"
        $smp = Join-Path $InstanceExeFolder 'create_message.exe';
        $result = .$smp -instance $InstanceName
        if($LASTEXITCODE -eq 1)
        {
            Write-VstsTaskError "Create Message finished with error => $result"
        }

        # TODO: Not Working
        Write-VstsTaskVerbose "Creating Forms"
        $smp = Join-Path $InstanceExeFolder 'samplemanagercommand.exe';
        $result = .$smp -instance $InstanceName -batch -task FormImport -all -directory (Join-Path $InstanceRootFolder "forms")
        if($LASTEXITCODE -eq 1)
        {
            Write-VstsTaskError "Create Message finished with error => $result"
        }

        Write-VstsTaskVerbose "Creating Entity Definition"
        $smp = Join-Path $InstanceExeFolder 'CreateEntityDefinition.exe';
        $result = .$smp -instance $InstanceName
        if($LASTEXITCODE -eq 1)
        {
            Write-VstsTaskError "Create Entity Definitions finished with error => $result"
        }

   }
   else {
       Write-VstsTaskError "Instance $InstanceName is not present.";
       Write-VstsTaskError "Execution is aborted.";
   }

} finally {
	Trace-VstsLeavingInvocation $MyInvocation
}