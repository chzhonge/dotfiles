# dotfiles

## Windows: Oh My Posh

Run this from the PowerShell edition you want to configure (PowerShell 7 recommended):

```powershell
.\setup_windows.ps1
```

The script installs Oh My Posh with WinGet when needed and adds a loader to
`$PROFILE.CurrentUserAllHosts` for that PowerShell edition. Existing profile content
is preserved and backed up before changes. Repeating the command does not add a
duplicate loader. Restart PowerShell after installation.

`powershell/profile.ps1` loads `oh-my-posh/maran.omp.json` relative to the checkout.
Keep the checkout in place. The theme mirrors `zsh/maran.zsh-theme`: user, host,
full path and Git branch on the first line; `=>` (or `#` for an administrator)
on the second. It uses plain text and does not require a Nerd Font.
