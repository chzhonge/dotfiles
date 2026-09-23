#!/bin/bash

# ==============================================================================
# Homebrew Setup Script for macOS
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
BREWFILE_PATH="$SCRIPT_DIR/homebrew/Brewfile"
CLEANUP=false

if [[ ${1:-} == "--cleanup" && $# -eq 1 ]]; then
  CLEANUP=true
elif (( $# != 0 )); then
  echo "用法：$0 [--cleanup]" >&2
  exit 2
fi

if [[ ! -f "$BREWFILE_PATH" ]]; then
  echo "❌ 找不到 Brewfile：$BREWFILE_PATH" >&2
  exit 1
fi

backup_existing() {
  local src="$1" dst="$2" backup suffix=0

  if [[ ! -e "$dst" && ! -L "$dst" ]] || [[ "$dst" -ef "$src" ]]; then
    return
  fi

  backup="$dst.bak.$(date +%Y%m%d%H%M%S)"
  while [[ -e "$backup" || -L "$backup" ]]; do
    ((suffix += 1))
    backup="$dst.bak.$(date +%Y%m%d%H%M%S).$suffix"
  done
  echo "📦 備份 $dst -> $backup"
  mv "$dst" "$backup"
}

echo "🔍 檢查 Command Line Tools (CLT)..."
if ! xcode-select -p &>/dev/null; then
  echo "🛠 尚未安裝 CLT，啟動安裝..."
  xcode-select --install
  echo "⏳ 請在跳出的視窗完成安裝後，重新執行此腳本。"
  exit 1
else
  echo "✅ 已安裝 Apple Xcode CLT"
fi

echo "🔍 檢查 Homebrew..."
BREW_BIN="$(command -v brew || true)"
if [[ -z "$BREW_BIN" ]]; then
  for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [[ -x "$candidate" ]]; then
      BREW_BIN="$candidate"
      break
    fi
  done
fi

if [[ -z "$BREW_BIN" ]]; then
  echo "🌐 安裝 Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ -x /opt/homebrew/bin/brew ]]; then
    BREW_BIN=/opt/homebrew/bin/brew
  elif [[ -x /usr/local/bin/brew ]]; then
    BREW_BIN=/usr/local/bin/brew
  else
    echo "❌ Homebrew 安裝後找不到 brew 指令" >&2
    exit 1
  fi
else
  echo "✅ 已安裝 Homebrew"
fi

if ! command -v brew &>/dev/null; then
  shellenv_line="eval \"\$($BREW_BIN shellenv)\""
  if ! grep -qxF "$shellenv_line" "$HOME/.zprofile" 2>/dev/null; then
    echo "📝 設定 Homebrew PATH..."
    printf '\n%s\n' "$shellenv_line" >> "$HOME/.zprofile"
  fi
fi
eval "$("$BREW_BIN" shellenv)"

echo "🔄 更新 Homebrew..."
"$BREW_BIN" update

echo "📦 開始安裝 Brewfile 中的軟體..."
"$BREW_BIN" bundle --file="$BREWFILE_PATH" --verbose

if [[ "$CLEANUP" == true ]]; then
  echo "🧹 清理不在 Brewfile 中的 Homebrew 套件..."
  "$BREW_BIN" bundle cleanup --file="$BREWFILE_PATH" --force
fi

echo "✨ 安裝 oh-my-zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "✅ 已安裝 oh-my-zsh"
fi

echo "📂 部署設定檔..."

# 定義複製函式 (含備份)
deploy_config() {
  local src="$1"
  local dst="$2"
  if [[ ! -f "$src" ]]; then
    echo "❌ 找不到來源檔案：$src" >&2
    return 1
  fi
  if [[ -e "$dst" || -L "$dst" ]] && cmp -s "$src" "$dst"; then
    echo "✅ 已部署 $(basename "$dst")"
    return
  fi
  mkdir -p "$(dirname "$dst")"
  backup_existing "$src" "$dst"
  echo "🚀 複製 $src -> $dst"
  cp "$src" "$dst"
}

# 執行部署
echo "🔗 使用 GNU Stow 連結主要設定檔..."
for config in \
  wezterm/.wezterm.lua \
  zsh/.zshrc \
  vim/.vimrc \
  tmux/.tmux.conf \
  git/.gitconfig \
  git/.gitignore; do
  backup_existing "$SCRIPT_DIR/$config" "$HOME/${config#*/}"
done
stow -d "$SCRIPT_DIR" -t "$HOME" wezterm zsh vim tmux git

echo "🚀 部署特殊路徑檔案..."
deploy_config "$SCRIPT_DIR/zsh/maran.zsh-theme" "$HOME/.oh-my-zsh/custom/themes/maran.zsh-theme"

# 安裝 vim-plug
echo "🔌 安裝 vim-plug..."
if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
  curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  echo "✅ vim-plug 安裝完成"
else
  echo "✅ vim-plug 已存在"
fi

# 自動安裝 Vim 插件
echo "📦 安裝 Vim 插件..."
vim +PlugInstall +qall

echo "✅ 全部套件安裝與設定部署完成！"
