# dotfiles

## Windows: CLI tools and Oh My Posh

Run this from the PowerShell edition you want to configure (PowerShell 7 recommended):

```powershell
.\setup_windows.ps1
```

The script installs Vim, Git, ripgrep (`rg`), fzf and Oh My Posh with WinGet
when needed and adds a loader to
`$PROFILE.CurrentUserAllHosts` for that PowerShell edition. Existing profile content
is preserved and backed up before changes. Repeating the command does not add a
duplicate loader. Restart PowerShell after installation.

`powershell/profile.ps1` loads `oh-my-posh/maran.omp.json` relative to the checkout.
Keep the checkout in place. The theme mirrors `zsh/maran.zsh-theme`: user, host,
full path and Git branch on the first line; `=>` (or `#` for an administrator)
on the second. It uses plain text and does not require a Nerd Font.

Windows Vim loads the shared `vim/.vimrc` through `~/_vimrc`. An existing
`_vimrc` is backed up before replacement. The script installs vim-plug in
`~/vimfiles/autoload/plug.vim`. After restarting WezTerm, run `vim` and
`:PlugInstall` to install the configured plugins. The vim-go installation hook
requires Go; install Go first if you use those plugins. Other Syntastic checkers
also require their respective language tools.

Windows setup backs up `~/.gitconfig` before changes, then includes the shared
`git/.gitconfig` before local settings. Identical local alias/color/push settings
are removed so future shared changes take effect; custom values, user identity,
credentials and `safe.directory` entries are preserved. Windows overrides point
the editor at Vim and the global ignore file at this checkout's `git/.gitignore`.
Existing local `core.hooksPath` is preserved; new setups use `git-hooks` relative
to each project's hook execution directory, matching this machine's previous
configuration (not Git's default `.git/hooks`). The Mac setup and shared config
are unchanged. Re-running setup does not duplicate the managed include. A linked
`~/.gitconfig` is rejected to avoid modifying its shared target.

Examples in PowerShell:

```powershell
vim README.md
rg 'TODO' .
rg --files | fzf
tree /F /A
tig
```

`tree` uses the Windows built-in command (`/F` includes files, `/A` uses ASCII).
Its flags differ from the Unix version. The PowerShell profile exposes the `tig`
bundled with Git for Windows, without putting Git's entire Unix tools directory
on PATH.

`fzf` is available as a standalone command; shell shortcuts are not configured.
Use `-SkipInstall` to configure files without installing packages or downloading
vim-plug, and `-ConfigHome` / `-ProfilePath` to target temporary configuration
paths for verification.
