Function Write-Log {
	param(
    [string]$JobName,
	[string]$Message,
	[int]$Type=1
    
	)
    try{
# Creating mutex object
        $mutexName = 'PatchAutomation'
        $mutex = New-Object 'Threading.Mutex' $false, $mutexName
# Import JSON file
        $Param = ConvertFrom-Json "$(get-content $(Join-Path C:\WindowsPatch_Automation\PsModule "PatchAutomation_Variables.json"))"
# Create date folder
        $Date = Get-Date -Format ddMMMyyyy
        $ScriptLogPath = $Param.ScriptLogPath + '\' + $Date
        if(!(Test-Path $ScriptLogPath)){
            New-Item -Path $ScriptLogPath -ItemType Dir -Force
        }
        $LogFilePath = $ScriptLogPath + "\" + $JobName.Replace('.ps1','') + ".Log"
		Switch($Type){
			1 {$Log = 'INFO'; $ForegroundColor = 'White'}
			2 {$Log = 'WARNING' ; $ForegroundColor = 'Yellow' }
			3 {$Log = 'Verbose'; $ForegroundColor = 'Yellow'}
			0 {$Log = 'Error'; $ForegroundColor = 'Red'}
		}
		$DateTimeStamp = Get-Date -Format "dd-MMM-yyyy HH:mm:ss"
# Grab the mutex. Will block until this process has it.
        $mutex.WaitOne() | Out-Null
        $Message = $Message.Replace('.ad.infosys.com','')
		Add-Content -Path $LogFilePath -Value "[$Log] - [$DateTimeStamp] - [$Message]"
        Write-Verbose "[$Log] - [$DateTimeStamp] - [$Message]" -Verbose
    }
    finally{
        $mutex.ReleaseMutex()
    }
}