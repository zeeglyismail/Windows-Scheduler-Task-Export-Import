# Import all scheduled tasks from the backup folder, recreating exact folder structure and task names
# Run this script as Administrator on the target server

$importPath = "C:\ums.osl.team"  # Change this if your backup folder has a different name/path

# Check if the folder exists
if (-not (Test-Path $importPath)) {
    Write-Error "Backup folder not found: $importPath"
    Write-Error "Please copy your exported folder here first."
    return
}

# Get all XML files recursively (from root and subfolders)
$xmlFiles = Get-ChildItem -Path $importPath -Filter "*.xml" -Recurse

if ($xmlFiles.Count -eq 0) {
    Write-Warning "No XML files found in $importPath"
    return
}

foreach ($file in $xmlFiles) {
    # Calculate the relative directory path inside the backup folder
    $relativeDir = $file.DirectoryName.Substring($importPath.Length).TrimStart('\')

    # Build the correct TaskPath for registration
    # Root tasks: TaskPath = "\"
    # Subfolder tasks: TaskPath = "\MyFolder\SubFolder\"
    $taskPath = if ($relativeDir) { "\" + ($relativeDir -replace '\\', '\') + "\" } else { "\" }

    # Task name comes from the filename (without .xml)
    $taskName = $file.BaseName

    # Read the full XML content
    $xmlContent = Get-Content -Path $file.FullName -Raw

    try {
        # Register the task -Force overwrites if it already exists
        Register-ScheduledTask -TaskName $taskName -TaskPath $taskPath -Xml $xmlContent -Force

        Write-Output "Successfully imported: $taskPath$taskName"
    }
    catch {
        Write-Error "Failed to import: $taskPath$taskName - Error: $($_.Exception.Message)"
    }
}

Write-Output ""
Write-Output "Import completed! $($xmlFiles.Count) tasks processed."
Write-Output "Now open Task Scheduler GUI to verify the tasks, enable them if needed, and re-enter credentials where required."