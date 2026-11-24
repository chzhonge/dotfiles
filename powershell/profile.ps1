# Use Tab for inline predictions while retaining ordinary completion.
$dotfilesReadLineOptions = Get-Command Set-PSReadLineOption -ErrorAction SilentlyContinue
if ($dotfilesReadLineOptions -and $dotfilesReadLineOptions.Parameters.ContainsKey('PredictionSource') -and
    -not [Console]::IsOutputRedirected) {
    if ($Host.UI.SupportsVirtualTerminal -and (Get-PSReadLineOption).PredictionSource -eq 'None') {
        Set-PSReadLineOption -PredictionSource History
    }
    Set-PSReadLineOption -PredictionViewStyle InlineView
    Set-PSReadLineKeyHandler -Key Tab -BriefDescription AcceptSuggestionOrComplete -ScriptBlock {
        param($key, $arg)

        $line = $null
        $cursor = 0
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
        # A history suggestion can replace a partial path and prevent cycling its matches.
        if ($cursor -eq $line.Length -and $line -notmatch '^\s*(?:ls|vim)\s') {
            $originalLine = $line
            [Microsoft.PowerShell.PSConsoleReadLine]::AcceptSuggestion($key, $arg)
            [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
            if ($line -cne $originalLine) { return }
        }
        [Microsoft.PowerShell.PSConsoleReadLine]::TabCompleteNext($key, $arg)
    }
}

# Some Windows Vim installers do not add the console executable to PATH.
if (-not (Get-Command vim -ErrorAction SilentlyContinue)) {
    foreach ($vimRoot in @("$env:LOCALAPPDATA/Programs/Vim", "$env:ProgramFiles/Vim", "${env:ProgramFiles(x86)}/Vim")) {
        if (-not (Test-Path -LiteralPath $vimRoot)) { continue }
        $vimExecutable = Get-ChildItem -Path "$vimRoot/vim.exe", "$vimRoot/vim*/vim.exe" -File -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if ($vimExecutable) {
            $env:PATH = $vimExecutable.DirectoryName + [System.IO.Path]::PathSeparator + $env:PATH
            break
        }
    }
}

# Expose Git for Windows' bundled tig without adding all Unix tools to PATH.
if (-not (Get-Command tig -ErrorAction SilentlyContinue)) {
    $dotfilesGitCommand = Get-Command git -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($dotfilesGitCommand) {
        $dotfilesGitRoot = Split-Path (Split-Path $dotfilesGitCommand.Source -Parent) -Parent
        $script:dotfilesTigExecutable = Join-Path $dotfilesGitRoot 'usr/bin/tig.exe'
        if (Test-Path -LiteralPath $script:dotfilesTigExecutable) {
            function global:tig { & $script:dotfilesTigExecutable @args }
        }
    }
}

# Resolve the theme relative to this file so the checkout can live anywhere.
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    $maranThemePath = Join-Path $PSScriptRoot '../oh-my-posh/maran.omp.json'
    oh-my-posh init pwsh --config $maranThemePath | Invoke-Expression
}

# Register Git argument completion after the prompt has been initialized.
if (Get-Module -ListAvailable -Name posh-git) {
    Import-Module posh-git
}
