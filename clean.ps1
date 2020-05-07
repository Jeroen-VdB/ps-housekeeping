$LogFile = $PSScriptRoot + "\clean.log"
Remove-Item -ErrorAction Ignore $LogFile

function LogInfo([string]$message) {
    $date = Get-Date
    Write-Host "[$date] $message" -Fore Blue
    Add-Content $logFile -Value "[$date][INFO] $message"
}

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

#######
# MAIN
#######
[xml]$XML = Get-Content ($PSScriptRoot + "\clean.config.xml")

foreach ($Clean in $XML.Config.Clean) {
    $Limit = (Get-Date).AddDays(-$Clean.AgeInDays)
    $Path = $Clean.Location

    LogInfo "Cleaning '$Path'."

    if ($Clean.Recurse.ToUpper() -eq "TRUE") {
        Get-ChildItem -Path $Path -File -Recurse | ForEach-Object { 
            if ($_.LastWriteTime -lt $Limit) {
                RemoveAndLog $_ 
            }
        }
    }
    else {
        Get-ChildItem -Path $Path -File | ForEach-Object { 
            if (!$_.PSIsContainer -and $_.LastWriteTime -lt $Limit) { 
                RemoveAndLog $_ 
            }
        }
    }

    if ($?) {
        LogSuccess "Cleaned '$Path'."
    }
    else {
        LogError "Unabled to clean '$Path'. Check if the folder exists, the script user has access and the config is correct."
    }

    if ($Clean.RemoveIfEmpty.ToUpper() -eq "TRUE") {
        if ($Clean.Recurse.ToUpper() -eq "TRUE") {
            Get-ChildItem -Path $Path -Recurse -Force | Where-Object { $_.PSIsContainer -and (Get-ChildItem -Path $_.FullName -Recurse -Force | Where-Object { !$_.PSIsContainer }) -eq $null -and $_.LastWriteTime -lt $Limit } | Remove-Item -Recurse -Force
        }
        else {
            Get-ChildItem $Path -Force | Where-Object { $_.PSIsContainer -and (Get-ChildItem -Path $_.FullName -Recurse -Force) -eq $null -and $_.LastWriteTime -lt $Limit } | Remove-Item -Recurse -Force
        }

        if ($?) {
            LogSuccess "Removed empty folder(s) in '$Path'."
        }
        else {
            LogError "Unabled to remove empty folder(s) in '$Path'. Check if the folder exists, the script user has access and the config is correct."
        }
    }
}

function RemoveAndLog([Object] $Item) {
    LogInfo "Removing: $($Item.FullName)"

    Remove-Item $_.FullName 
        
    if ($?) {
        LogSuccess "Removed: $($Item.FullName)"
    }
    else {
        LogError "Unable to remove: $($Item.FullName). Make sure the script user has access and the config is correct."
    }
}
