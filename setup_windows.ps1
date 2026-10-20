[CmdletBinding()]
param(
    [string]$ProfilePath = $PROFILE.CurrentUserAllHosts,
    [string]$ConfigHome = $env:USERPROFILE,
    [switch]$SkipInstall
)

$ErrorActionPreference = 'Stop'
$repoRoot = $PSScriptRoot
$managedProfile = Join-Path $repoRoot 'powershell/profile.ps1'

if (-not $SkipInstall) {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw 'WinGet is required. Install App Installer from Microsoft Store, then retry.'
    }
    $packages = @(
        @{ Id = 'JanDeDobbeleer.OhMyPosh'; Command = 'oh-my-posh' },
        @{ Id = 'Git.Git'; Command = 'git' },
        @{ Id = 'vim.vim'; Command = 'vim' },
        # Check the package rather than Codex's private rg executable on PATH.
        @{ Id = 'BurntSushi.ripgrep.MSVC'; Command = $null },
        @{ Id = 'junegunn.fzf'; Command = 'fzf' }
    )
    foreach ($package in $packages) {
        if ($package.Command -and (Get-Command $package.Command -ErrorAction SilentlyContinue)) {
            continue
        }
        & winget list --id $package.Id -e --source winget | Out-Null
        if ($LASTEXITCODE -eq 0) { continue }
        & winget install --id $package.Id -e --source winget
        if ($LASTEXITCODE -ne 0) {
            throw "$($package.Id) installation failed (exit code $LASTEXITCODE)."
        }
    }
}

# Source the shared Vim settings without requiring administrator symlink rights.
$vimrcPath = Join-Path $ConfigHome '_vimrc'
$sharedVimrc = (Join-Path $repoRoot 'vim/.vimrc').Replace('\', '/').Replace("'", "''")
$vimLoader = "execute 'source ' . fnameescape('$sharedVimrc')`n"
New-Item -ItemType Directory -Path $ConfigHome -Force | Out-Null
if (-not (Test-Path -LiteralPath $vimrcPath) -or [System.IO.File]::ReadAllText($vimrcPath) -ne $vimLoader) {
    if (Test-Path -LiteralPath $vimrcPath) {
        Copy-Item -LiteralPath $vimrcPath -Destination "$vimrcPath.$([guid]::NewGuid().ToString('N')).bak"
    }
    [System.IO.File]::WriteAllText($vimrcPath, $vimLoader, [System.Text.UTF8Encoding]::new($false))
}

$plugPath = Join-Path $ConfigHome 'vimfiles/autoload/plug.vim'
if (-not $SkipInstall -and -not (Test-Path -LiteralPath $plugPath)) {
    New-Item -ItemType Directory -Path (Split-Path $plugPath -Parent) -Force | Out-Null
    $plugTemp = "$plugPath.download"
    try {
        Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim' -OutFile $plugTemp
        Move-Item -LiteralPath $plugTemp -Destination $plugPath
    } finally {
        if (Test-Path -LiteralPath $plugTemp) { Remove-Item -LiteralPath $plugTemp }
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
Write-Host 'Restart WezTerm, then run vim and :PlugInstall to install the shared Vim plugins.'
Write-Host 'The vim-go plugin requires Go for its GoUpdateBinaries installation hook.'
