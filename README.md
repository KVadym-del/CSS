# CSS.ps1

A safe, interactive PowerShell script for recursively deleting specified folders from a directory tree.

## Features

- **Safe**: Preview mode (`-WhatIf`), confirmation prompts, and detailed logging
- **Informative**: Shows folder paths and calculates total size before deletion
- **Flexible**: Target specific directories or use current location

## Usage

### Basic Examples

```powershell
# Preview deletion of Visual Studio and vcpkg folders
.\Clean-Folders.ps1 -FolderNames ".vs", "vcpkg_installed" -WhatIf

# Clean build artifacts from a project
.\Clean-Folders.ps1 -f "bin", "obj" -Path "C:\Projects\MyApp"

# Clean temporary folders without confirmation
.\Clean-Folders.ps1 -f "temp", "tmp" -Force
```

### Parameters

- `-Path <string>` - Starting directory (default: current location)
- `-FolderNames <string[]>` / `-f` - Array of folder names to delete (required)
- `-Force` - Skip confirmation prompt
- `-WhatIf` - Show what would be deleted without removing anything
