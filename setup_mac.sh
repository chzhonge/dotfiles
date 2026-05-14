#!/bin/bash

set -euo pipefail

HOME_PATH=${HOME}
TMP_DIR="./tmp-setup"

MACPORTS_VER="2.11.4"       # 你要的 MacPorts 版本
MACOS_VER_NAME="15-Sequoia"   # macOS 發行版名稱 (Ventura / Sonoma / Monterey ...)

PORTS_PATH="/opt/local/bin/port"
PORTS_FILE="${1:-ports.txt}"   # 可用參數覆蓋：./install_ports.sh my-ports.txt

echo "建立 temp 資料夾"
mkdir -p "$TMP_DIR"

echo "🔍 檢查 Command Line Tools (CLT)..."
if ! xcode-select -p &>/dev/null; then
  echo "🛠 尚未安裝 CLT，啟動安裝..."
  xcode-select --install
  echo "⏳ 請在跳出的視窗完成安裝後，重新執行此腳本。"
  exit 1
else
  echo "✅ 已安裝 Apple Xcode CLT"
fi

if ! ${PORTS_PATH} version &>/dev/null; then
  PKG_URL="https://github.com/macports/macports-base/releases/download/v${MACPORTS_VER}/MacPorts-${MACPORTS_VER}-${MACOS_VER_NAME}.pkg"
  PKG_FILE="${TMP_DIR}/macports-${MACPORTS_VER}-${MACOS_VER_NAME}.pkg"

  echo "🌐 下載 MacPorts ${MACPORTS_VER} for macOS ${MACOS_VER_NAME} ..."
  curl -L --fail --retry 3 --retry-delay 2 -o "$PKG_FILE" "$PKG_URL"

  echo "🚀 使用 installer 安裝中..."
  sudo installer -pkg "$PKG_FILE" -target /

  echo "🧹 刪除暫存安裝檔 $PKG_FILE"
  rm -f "$PKG_FILE"

  echo "✨ 完成！重新開啟 Terminal 並執行："
else
  echo "✅ 已安裝 MacPorts"
fi

ZSHRC_PATH="${HOME_PATH}/.zshrc"
# https://guide.macports.org/chunked/installing.shell.html
LINE='export PATH=/opt/local/bin:/opt/local/sbin:$PATH'

# 1. 檢查檔案是否存在
if [[ ! -f "${ZSHRC_PATH}" ]]; then
    echo "ℹ️  找不到 ${ZSHRC_PATH}，建立中..."
    touch "${ZSHRC_PATH}"
fi

# 2. 檢查是否已包含完整的那一行
if ! grep -qxF "$LINE" "${ZSHRC_PATH}"; then
    echo "📝 新增 PATH 設定到 ${ZSHRC_PATH}"
    echo "$LINE" >> "${ZSHRC_PATH}"
else
    echo "✅ ${ZSHRC_PATH} 已包含 PATH 設定"
fi

if [[ ! -f "$PORTS_FILE" ]]; then
  echo "❌ 找不到清單檔：$PORTS_FILE"
  echo "請建立一個檔案，每行一個 port（可含 variants），可加註解。例如："
  echo "  git"
  echo "  vim +huge +python311"
  echo "  # ffmpeg +nonfree"
  exit 1
fi

PORTS=()
while IFS= read -r line; do
  PORTS+=("$line")
done < <(sed -E 's/#.*$//' "${PORTS_FILE}" | sed '/^[[:space:]]*$/d')

if ((${#PORTS[@]} == 0)); then
  echo "ℹ️  $PORTS_FILE 沒有可安裝項目（全是空行或註解）。"
  exit 0
fi

echo "🔄 MacPorts selfupdate..."
sudo ${PORTS_PATH} -v selfupdate

echo "⬆️  MacPorts upgrade outdated..."
sudo ${PORTS_PATH} -v upgrade outdated || true

echo "📦 MacPorts install packages from $PORTS_FILE ..."
failed=()
for p in "${PORTS[@]}"; do
  echo "→ installing: $p"
  # 用 -N 非互動；用 `--` 防止某些字元被誤解
  if ! sudo ${PORTS_PATH} -N install -- $p; then
    echo "⚠️  failed: $p"
    failed+=("$p")
  fi
done

echo "🔎 MacPorts rev-upgrade（修壞鏈）..."
sudo ${PORTS_PATH} -v rev-upgrade || true

echo "🧹 Macports reclaim（清理舊檔）..."
sudo ${PORTS_PATH} reclaim -f || true

if ((${#failed[@]})); then
  echo "❌ 以下套件安裝失敗（請逐一檢查 variants/相依性）："
  printf ' - %s\n' "${failed[@]}"
  exit 1
else
  echo "✅ 全部套件安裝完成"
fi 


