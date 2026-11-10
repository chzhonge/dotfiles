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
        @{ Id = 'GitHub.cli'; Command = 'gh' },
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

# Put the shared Git config first, followed by machine-specific overrides.
$gitCommand = Get-Command git -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $gitCommand) {
    foreach ($gitCandidate in @("$env:ProgramFiles/Git/cmd/git.exe", "$env:LOCALAPPDATA/Programs/Git/cmd/git.exe")) {
        if (Test-Path -LiteralPath $gitCandidate) {
            $gitCommand = Get-Item -LiteralPath $gitCandidate
            break
        }
    }
}
if (-not $gitCommand) { throw 'Git was not found. Restart PowerShell after installation and retry.' }
$gitExe = if ($gitCommand -is [System.IO.FileInfo]) { $gitCommand.FullName } else { $gitCommand.Source }

$gitConfigPath = Join-Path $ConfigHome '.gitconfig'
$sharedGitConfig = (Join-Path $repoRoot 'git/.gitconfig').Replace('\', '/')
$gitIgnorePath = (Join-Path $repoRoot 'git/.gitignore').Replace('\', '/')
New-Item -ItemType Directory -Path $ConfigHome -Force | Out-Null
if ((Test-Path -LiteralPath $gitConfigPath) -and (Get-Item -LiteralPath $gitConfigPath).LinkType) {
    throw "$gitConfigPath is a link. Use a regular local Git config before running Windows setup."
}

# Git's editor runs outside PowerShell, so resolve Vim rather than using a function.
$vimCommand = Get-Command vim -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
$gitEditor = if ($vimCommand) { '"' + $vimCommand.Source.Replace('\', '/') + '"' } else { 'vim' }
if (-not $vimCommand) {
    foreach ($vimRoot in @("$env:LOCALAPPDATA/Programs/Vim", "$env:ProgramFiles/Vim", "${env:ProgramFiles(x86)}/Vim")) {
        if (-not (Test-Path -LiteralPath $vimRoot)) { continue }
        $vimFile = Get-ChildItem -Path "$vimRoot/vim.exe", "$vimRoot/vim*/vim.exe" -File -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if ($vimFile) {
            $gitEditor = '"' + $vimFile.FullName.Replace('\', '/') + '"'
            break
        }
    }
}

$gitTemp = Join-Path $ConfigHome ('.gitconfig.' + [guid]::NewGuid().ToString('N') + '.tmp')
$includeTemp = "$gitTemp.include"
function Invoke-SetupGitConfig {
    param([string[]]$GitArguments, [int[]]$AllowedExitCodes = @(0))
    $output = & $gitExe @GitArguments
    if ($LASTEXITCODE -notin $AllowedExitCodes) { throw "Git configuration failed (exit code $LASTEXITCODE)." }
    $output
}
try {
    $originalGitConfig = if (Test-Path -LiteralPath $gitConfigPath) {
        [System.IO.File]::ReadAllText($gitConfigPath)
    } else { '' }
    [System.IO.File]::WriteAllText($gitTemp, $originalGitConfig, [System.Text.UTF8Encoding]::new($false))
    # Preserve custom values; only identical common defaults move into the include.
    $commonKeys = Invoke-SetupGitConfig -GitArguments @('config', '--file', $sharedGitConfig, '--name-only', '--get-regexp', '^(alias|color|push)\.') -AllowedExitCodes @(0, 1)
    foreach ($key in $commonKeys) {
        $localValues = @(Invoke-SetupGitConfig -GitArguments @('config', '--file', $gitTemp, '--no-includes', '--get-all', $key) -AllowedExitCodes @(0, 1))
        $sharedValue = Invoke-SetupGitConfig -GitArguments @('config', '--file', $sharedGitConfig, '--get', $key)
        if ($localValues.Count -eq 1 -and $localValues[0] -ceq $sharedValue) {
            $null = Invoke-SetupGitConfig -GitArguments @('config', '--file', $gitTemp, '--unset-all', $key)
        }
    }
    # Retain this machine's existing hook policy. New setups use per-project git-hooks.
    $localHooks = @(Invoke-SetupGitConfig -GitArguments @('config', '--file', $gitTemp, '--no-includes', '--get-all', 'core.hooksPath') -AllowedExitCodes @(0, 1))
    $windowsHooks = if ($localHooks.Count) { $localHooks[-1] } else { 'git-hooks' }
    $null = Invoke-SetupGitConfig -GitArguments @('config', '--file', $gitTemp, '--fixed-value', '--unset-all', 'include.path', $sharedGitConfig) -AllowedExitCodes @(0, 5)
    foreach ($override in @(
        @('core.editor', $gitEditor),
        @('core.excludesFile', $gitIgnorePath),
        @('core.hooksPath', $windowsHooks)
    )) {
        $null = Invoke-SetupGitConfig -GitArguments @('config', '--file', $gitTemp, '--replace-all', $override[0], $override[1])
    }
    $null = Invoke-SetupGitConfig -GitArguments @('config', '--file', $includeTemp, '--add', 'include.path', $sharedGitConfig)
    $newGitConfig = [System.IO.File]::ReadAllText($includeTemp) + [System.IO.File]::ReadAllText($gitTemp)
    if ($newGitConfig -cne $originalGitConfig) {
        if (Test-Path -LiteralPath $gitConfigPath) {
            $gitBackup = "$gitConfigPath.$([guid]::NewGuid().ToString('N')).bak"
            Copy-Item -LiteralPath $gitConfigPath -Destination $gitBackup
            Write-Host "Git config backup: $gitBackup"
        }
        [System.IO.File]::WriteAllText($gitTemp, $newGitConfig, [System.Text.UTF8Encoding]::new($false))
        Move-Item -LiteralPath $gitTemp -Destination $gitConfigPath -Force
    }
} finally {
    foreach ($temporaryConfig in @($gitTemp, $includeTemp)) {
        if (Test-Path -LiteralPath $temporaryConfig) { Remove-Item -LiteralPath $temporaryConfig }
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
Write-Host "Git configured: $gitConfigPath"
Write-Host 'Restart WezTerm, then run vim and :PlugInstall to install the shared Vim plugins.'
Write-Host 'The vim-go plugin requires Go for its GoUpdateBinaries installation hook.'
