# Lazy-Organizer.ps1
# A PowerShell script to automatically organize files into categorized folders based on extensions.

$TargetDir = Get-Location
$ActionTaken = $false

# Define the file type mapping
$Categories = @{
    "Images"     = @(".jpg", ".jpeg", ".png", ".gif", ".bmp", ".svg", ".webp", ".ico")
    "Documents"  = @(".pdf", ".doc", ".docx", ".txt", ".rtf", ".odt", ".xls", ".xlsx", ".ppt", ".pptx", ".csv")
    "Archives"   = @(".zip", ".rar", ".7z", ".tar", ".gz")
    "Audio"      = @(".mp3", ".wav", ".flac", ".m4a", ".aac")
    "Video"      = @(".mp4", ".mkv", ".mov", ".avi", ".wmv", ".flv")
    "Installers" = @(".exe", ".msi", ".dmg", ".pkg")
    "Code"       = @(".py", ".js", ".html", ".css", ".java", ".cpp", ".c", ".sh", ".ps1", ".bat")
}

Write-Host "--- Lazy-Organizer Starting ---" -ForegroundColor Cyan
Write-Host "Organizing files in: $TargetDir"

# Get all files in the current directory (excluding directories and the script itself)
$Files = Get-ChildItem -Path $TargetDir -File | Where-Object { $_.Name -ne $MyInvocation.MyCommand.Name }

foreach ($File in $Files) {
    $Extension = $File.Extension.ToLower()
    $Moved = $false

    foreach ($Category in $Categories.Keys) {
        if ($Categories[$Category] -contains $Extension) {
            $DestFolder = Join-Path -Path $TargetDir -ChildPath $Category
            
            # Create folder if it doesn't exist
            if (-not (Test-Path -Path $DestFolder)) {
                New-Item -ItemType Directory -Path $DestFolder | Out-Null
                Write-Host "Created category folder: $Category" -ForegroundColor Gray
            }

            # Handle file name collisions
            $DestFile = Join-Path -Path $DestFolder -ChildPath $File.Name
            $Counter = 1
            while (Test-Path -Path $DestFile) {
                $FileNameWithoutExt = $File.BaseName
                $NewName = "{0} ({1}){2}" -f $FileNameWithoutExt, $Counter, $File.Extension
                $DestFile = Join-Path -Path $DestFolder -ChildPath $NewName
                $Counter++
            }

            # Move the file
            Move-Item -Path $File.FullName -Destination $DestFile
            if ($Counter -gt 1) {
                Write-Host "Moved (Renamed): $($File.Name) -> $Category/$($DestFile | Split-Path -Leaf)" -ForegroundColor Green
            } else {
                Write-Host "Moved: $($File.Name) -> $Category/" -ForegroundColor Green
            }
            $Moved = $true
            $ActionTaken = $true
            break
        }
    }

    if (-not $Moved) {
        Write-Host "Skipped: $($File.Name) (No matching category)" -ForegroundColor Yellow
    }
}

if (-not $ActionTaken) {
    Write-Host "No files found to organize." -ForegroundColor Yellow
} else {
    Write-Host "--- Organization Complete! ---" -ForegroundColor Cyan
}
