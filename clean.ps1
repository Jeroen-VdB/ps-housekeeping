$LogFile = $PSScriptRoot + "\clean.log"
Remove-Item -ErrorAction Ignore $LogFile

function LogSuccess([string]$message) {
    $date = Get-Date
    Write-Host "[$date] $message" -Fore Green
    Add-Content $logFile -Value "[$date][SUCCESS] $message"
}

function LogError([string]$message) {
    $date = Get-Date
    Write-Host "[$date] $message" -Fore Red
    Add-Content $logFile -Value "[$date][ERROR] $message"
}

[xml]$XML = Get-Content ($PSScriptRoot + "\clean.config.xml")

foreach($Clean in $XML.Config.Clean)
{
    $Limit = (Get-Date).AddDays(-$Clean.AgeInDays)
    $Path = $Clean.Location

    if ($Clean.IncludeSubFolders.ToUpper() -eq "TRUE") {
        Get-ChildItem -Path $Clean.Location -File -Recurse | Where-Object { $_.LastWriteTime -lt $Limit } | Remove-Item
    } else {
        $CurrentFolderFiles = $Clean.Location + "\*.*"
        Remove-Item $CurrentFolderFiles | Where-Object { ! $_.PSIsContainer -and $_.LastWriteTime -lt $Limit }
    }

    if ($?) {
        LogSuccess "Cleaned '$Path'."
    } else {
        LogError "Unabled to clean '$Path'. Check if the folder exists, the script user has access and the config is correct."
    }
}