Import-Module ..\BuildAndReleaseTask\ps_modules\VstsTaskSdk

Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create('..\BuildAndReleaseTask\Create-SMInstance.ps1')) -Verbose
