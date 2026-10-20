[CmdletBinding()]
param(
    [string]$ProfilePath = $PROFILE.CurrentUserAllHosts,
    [switch]$SkipInstall
)

$ErrorActionPreference = 'Stop'
$repoRoot = $PSScriptRoot
$managedProfile = Join-Path $repoRoot 'powershell/profile.ps1'

if (-not $SkipInstall -and -not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw 'WinGet is required. Install App Installer from Microsoft Store, then retry.'
    }
    & winget install --id JanDeDobbeleer.OhMyPosh -e --source winget
    if ($LASTEXITCODE -ne 0) {
        throw "Oh My Posh installation failed (exit code $LASTEXITCODE)."
    }
}

# Keep existing profile content and append this loader only once.
$escapedPath = $managedProfile.Replace("'", "''")
$loader = ". '$escapedPath'"
$existing = if (Test-Path -LiteralPath $ProfilePath) {
    [System.IO.File]::ReadAllText($ProfilePath)
} else { '' }

if (($existing -split '\r?\n') -notcontains $loader) {
    $profileDirectory = Split-Path $ProfilePath -Parent
    if ($profileDirectory) {
        New-Item -ItemType Directory -Path $profileDirectory -Force | Out-Null
    }
    # Back up an existing profile before modifying it; preserve its encoding.
    if (Test-Path -LiteralPath $ProfilePath) {
        $backupPath = "$ProfilePath.$([guid]::NewGuid().ToString('N')).bak"
        Copy-Item -LiteralPath $ProfilePath -Destination $backupPath
        $reader = [System.IO.StreamReader]::new($ProfilePath, $true)
        try {
            $null = $reader.ReadToEnd()
            $profileEncoding = $reader.CurrentEncoding
        } finally { $reader.Dispose() }
    } else {
        $profileEncoding = [System.Text.UTF8Encoding]::new($true)
    }
    [System.IO.File]::WriteAllText($ProfilePath, $existing + "`r`n" + $loader + "`r`n", $profileEncoding)
}

Write-Host "Profile configured: $ProfilePath"
Write-Host 'Restart PowerShell to load the maran theme.'
