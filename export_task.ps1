
$exportPath = "C:\TaskBackup"
if (-not (Test-Path $exportPath)) {
    New-Item -Path $exportPath -ItemType Directory | Out-Null
}

# Get tasks: exclude Microsoft paths AND tasks authored by Microsoft
$tasks = Get-ScheduledTask | Where-Object {
    $_.TaskPath -notlike "\Microsoft*" -and
    $_.Author -notlike "*Microsoft*" -and
    $_.Author -notlike "N/A"  # Optional: exclude some system ones; remove if needed
}

foreach ($task in $tasks) {
    $relativePath = $task.TaskPath.Trim('\')
    $folderPath = Join-Path $exportPath $relativePath
    
    if (-not (Test-Path $folderPath)) {
        New-Item -Path $folderPath -ItemType Directory | Out-Null
    }
    
    $safeName = $task.TaskName -replace '[\\/:*?"<>|]', '_'
    $filePath = Join-Path $folderPath "$safeName.xml"
    
    $xml = Export-ScheduledTask -TaskName $task.TaskName -TaskPath $task.TaskPath
    $xml | Out-File -FilePath $filePath -Encoding UTF8
    
    Write-Output "Exported custom task: $($task.TaskPath)$($task.TaskName) -> $filePath"
}

Write-Output "Export completed. $($tasks.Count) custom tasks saved to $exportPath"