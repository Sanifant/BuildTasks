Import-Module ..\BuildAndReleaseTask\ps_modules\VstsTaskSdk
# Task variable 'Build.SourcesDirectory':
$env:BUILD_SOURCESDIRECTORY = "D:\Temp"

Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create('..\BuildAndReleaseTask\Create-SMInstance.ps1')) -Verbose
