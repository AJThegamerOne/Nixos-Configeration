#!/usr/bin/env bash
set -euo pipefail

# Best-effort native package install for CachyOS/Arch-based distros.
# Review before running. Some packages come from AUR.

if command -v paru >/dev/null 2>&1; then
  AUR=paru
elif command -v yay >/dev/null 2>&1; then
  AUR=yay
else
  AUR=""
fi

PACMAN_PKGS=(
  brave-browser
  gnutar
  steam
  fastfetch
  git
  github-cli
  ghostty
  discord
  prismlauncher
  lutris
  mangohud
  goverlay
  gamemode
  lib32-gamemode
  pipewire-pulse
  ttf-hack-nerd
)

AUR_PKGS=(
  vesktop-bin
  protonplus
  amnezia-vpn
  opencode-bin
  zoom
  faugus-launcher
  lunar-client
  spotifast-bin
)

echo "==> Installing pacman packages..."
sudo pacman -S --needed "${PACMAN_PKGS[@]}"

if [[ -n "$AUR" ]]; then
  echo "==> Installing AUR packages with $AUR..."
  "$AUR" -S --needed "${AUR_PKGS[@]}"
else
  echo "==> No AUR helper found (paru/yay). Install these manually if needed:"
  printf '  - %s\n' "${AUR_PKGS[@]}"
fi

echo "==> Notes"
echo "- steam-run has no direct Arch equivalent; most native games run without it."
echo "- NixOS-only options/services from configuration.nix must be configured manually on Arch/CachyOS."
