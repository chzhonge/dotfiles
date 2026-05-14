#!/bin/bash

# ==============================================================================
# Homebrew Setup Script for macOS
# ==============================================================================

set -euo pipefail

BREWFILE_PATH="./homebrew/Brewfile"

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
if ! command -v brew &>/dev/null; then
  echo "🌐 安裝 Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  
  # 設定 Shell 環境變數 (針對 Apple Silicon)
  if [[ $(uname -m) == "arm64" ]]; then
    echo "📝 設定 Homebrew PATH (Apple Silicon)..."
    (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> "$HOME/.zprofile"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
else
  echo "✅ 已安裝 Homebrew"
  echo "🔄 更新 Homebrew..."
  brew update
fi

if [[ ! -f "$BREWFILE_PATH" ]]; then
  echo "❌ 找不到 Brewfile：$BREWFILE_PATH"
  exit 1
fi

echo "📦 開始安裝 Brewfile 中的軟體..."
brew bundle --file="$BREWFILE_PATH" --verbose

echo "🧹 清理不在 Brewfile 中的多餘套件..."
brew bundle cleanup --file="$BREWFILE_PATH" --force

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
  if [ -f "$src" ] || [ -d "$src" ]; then
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
      echo "📦 備份現有的 $(basename "$dst") -> $(basename "$dst").bak"
      mv "$dst" "$dst.bak"
    fi
    echo "🚀 複製 $src -> $dst"
    mkdir -p "$(dirname "$dst")"
    cp -R "$src" "$dst"
  else
    echo "⚠️  找不到來源檔案: $src"
  fi
}

# 執行部署
echo "🔗 使用 GNU Stow 連結主要設定檔..."
stow -t ~ wezterm zsh vim tmux git

echo "🚀 部署特殊路徑檔案..."
deploy_config "./zsh/maran.zsh-theme" "$HOME/.oh-my-zsh/custom/themes/maran.zsh-theme"

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
