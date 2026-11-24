#!/usr/bin/env bash
# Install AJ's NixOS user dotfiles into $HOME.
# Run from anywhere: ./install.sh
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES="$REPO_DIR/dotfiles"

usage() {
  cat <<'EOF'
Usage: ./install.sh

Copies the dotfiles in this repo into your home directory:
  - fastfetch config + NixOS logo  -> ~/.config/fastfetch/
  - Ghostty config                 -> ~/.config/ghostty/
  - Konsole profile + config       -> ~/.local/share/konsole/, ~/.config/konsolerc
  - KDE Plasma config              -> ~/.config/
  - TokyoNight color scheme        -> ~/.local/share/color-schemes/
  - zshrc                          -> ~/.zshrc

Existing files are backed up to <file>.bak.<timestamp> before being replaced.
Font and KDE launcher caches are refreshed at the end.
EOF
}

case "${1:-}" in
  -h|--help) usage; exit 0 ;;
  "") ;;
  *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
esac

if [[ ! -d "$DOTFILES" ]]; then
  echo "Error: dotfiles directory not found at $DOTFILES" >&2
  exit 1
fi

backup() {
  local target="$1"
  if [[ -e "$target" || -L "$target" ]]; then
    local saved="${target}.bak.$(date +%Y%m%d-%H%M%S)"
    cp -a -- "$target" "$saved"
    echo "    backed up -> $saved"
  fi
}

install_file() {
  local src="$1"
  local dest="$2"
  mkdir -p -- "$(dirname -- "$dest")"
  backup "$dest"
  cp -- "$src" "$dest"
  echo "  -> $dest"
}

echo "==> Installing fastfetch config"
install_file "$DOTFILES/fastfetch/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
install_file "$DOTFILES/fastfetch/logo/nixos_logo_2.webp" "$HOME/.config/fastfetch/logo/nixos_logo_2.webp"

echo "==> Installing Ghostty config (TokyoNight Storm)"
install_file "$DOTFILES/ghostty/config" "$HOME/.config/ghostty/config"

echo "==> Installing Konsole profile (Hack Nerd Font)"
install_file "$DOTFILES/konsole/NerdFont.profile" "$HOME/.local/share/konsole/NerdFont.profile"
install_file "$DOTFILES/konsole/konsolerc" "$HOME/.config/konsolerc"

echo "==> Installing KDE Plasma config"
for f in "$DOTFILES"/kde/k* "$DOTFILES"/kde/plasma*; do
  [[ -f "$f" ]] || continue
  install_file "$f" "$HOME/.config/$(basename -- "$f")"
done
install_file "$DOTFILES/kde/color-schemes/TokyoNight.colors" \
  "$HOME/.local/share/color-schemes/TokyoNight.colors"

echo "==> Installing zshrc (fastfetch on shell startup)"
install_file "$DOTFILES/zshrc" "$HOME/.zshrc"

echo "==> Refreshing caches"
if command -v fc-cache >/dev/null 2>&1; then
  fc-cache -f
  echo "  -> font cache refreshed"
fi
if command -v kbuildsycoca6 >/dev/null 2>&1; then
  kbuildsycoca6 --noincremental
  echo "  -> KDE launcher cache refreshed"
fi

echo "==> Done. Open a new terminal to see the changes."
