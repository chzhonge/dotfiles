# Resolve the theme relative to this file so the checkout can live anywhere.
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    $maranThemePath = Join-Path $PSScriptRoot '../oh-my-posh/maran.omp.json'
    oh-my-posh init pwsh --config $maranThemePath | Invoke-Expression
}
