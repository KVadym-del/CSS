<#
.SYNOPSIS
Recursively deletes specified folders from a directory.

.DESCRIPTION
Searches for and removes specified folders recursively from a target directory.
Provide a list of folder names to delete via the -FolderNames parameter.

.PARAMETER Path
The root directory to start searching from. Defaults to current directory.

.PARAMETER FolderNames
Array of folder names to search for and delete (e.g., ".vs", "bin", "obj").

.PARAMETER Force
Skips the confirmation prompt before deletion.

.PARAMETER WhatIf
Shows what would be deleted without actually removing anything.

.EXAMPLE
.\Clean-Folders.ps1 -FolderNames ".vs", "vcpkg_installed" -WhatIf
Preview deletion of .vs and vcpkg_installed folders

.EXAMPLE
.\Clean-Folders.ps1 -FolderNames "bin", "obj", "node_modules" -Path "C:\Projects" -Force
Delete bin, obj, and node_modules folders from C:\Projects without confirmation

.EXAMPLE
.\Clean-Folders.ps1 -f ".cache", "temp" -WhatIf
Use alias -f for quick typing
#>
param(
    [Parameter(Position = 0)]
    [string]$Path = (Get-Location),

    [Parameter(Mandatory = $true)]
    [Alias("f")]
    [string[]]$FolderNames,

    [switch]$Force,

    [switch]$WhatIf
)

$ErrorActionPreference = "Stop"

$folderList = $FolderNames -join ", "
Write-Host "🔍 Searching for folders: [$folderList]" -ForegroundColor Cyan
Write-Host "📂 Starting from: $Path" -ForegroundColor Cyan

$foldersToDelete = Get-ChildItem -Path $Path -Recurse -Directory -Force |
    Where-Object { $FolderNames -contains $_.Name } |
    Select-Object -ExpandProperty FullName

if ($foldersToDelete.Count -eq 0) {
    Write-Host "✅ No matching folders found." -ForegroundColor Green
    exit 0
}

Write-Host "`n📂 Found $($foldersToDelete.Count) folder(s) to delete:" -ForegroundColor Yellow
$foldersToDelete | ForEach-Object {
    Write-Host "  - $_" -ForegroundColor Gray
}

try {
    $totalSize = ($foldersToDelete | ForEach-Object {
        (Get-ChildItem $_ -Recurse -Force -ErrorAction SilentlyContinue |
            Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
    } | Measure-Object -Sum).Sum

    if ($totalSize) {
        $sizeMB = [math]::Round($totalSize / 1MB, 2)
        $sizeGB = [math]::Round($totalSize / 1GB, 2)
        if ($sizeGB -ge 1) {
            Write-Host "`n💾 Total size: $sizeGB GB" -ForegroundColor Cyan
        } else {
            Write-Host "`n💾 Total size: $sizeMB MB" -ForegroundColor Cyan
        }
    }
} catch {
    Write-Host "`n⚠️  Could not calculate total size" -ForegroundColor Yellow
}

if (!$Force -and !$WhatIf) {
    Write-Host "`n❓ Are you sure you want to delete these folders? (Y/N): " -ForegroundColor Red -NoNewline
    $response = Read-Host
    if ($response -ne 'Y' -and $response -ne 'y') {
        Write-Host "🛑 Operation cancelled." -ForegroundColor Yellow
        exit 0
    }
}

$deletedCount = 0
$failedCount = 0

foreach ($folder in $foldersToDelete) {
    try {
        if ($WhatIf) {
            Write-Host "[WHATIF] Would delete: $folder" -ForegroundColor Magenta
            $deletedCount++
        } else {
            Write-Host "🗑️  Deleting: $folder" -ForegroundColor Red
            Remove-Item -Path $folder -Recurse -Force -ErrorAction Stop
            $deletedCount++
        }
    } catch {
        Write-Host "❌ Failed to delete $folder : $_" -ForegroundColor Red
        $failedCount++
    }
}

Write-Host "`n" -NoNewline
if ($WhatIf) {
    Write-Host "📊 WHATIF MODE: Would have deleted $deletedCount folder(s)" -ForegroundColor Magenta
} else {
    if ($failedCount -eq 0) {
        Write-Host "✅ Successfully deleted $deletedCount folder(s)" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Deleted $deletedCount folder(s), failed to delete $failedCount folder(s)" -ForegroundColor Yellow
    }
}
