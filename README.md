<div align="center">

# AJ's NixOS Config

**Gaming-first NixOS desktop — CachyOS kernel, KDE Plasma 6, and a carefully tuned Steam/Proton stack.**

[![NixOS](https://img.shields.io/badge/OS-NixOS-7BAFDE?logo=nixos&logoColor=white)](https://nixos.org)
[![KDE Plasma](https://img.shields.io/badge/Desktop-Plasma%206-1E97E0?logo=kde&logoColor=white)](https://plasma.kde.org)
[![Kernel](https://img.shields.io/badge/Kernel-CachyOS%20BORE-orange)](https://github.com/xddxdd/nix-cachyos-kernel)
[![Flakes](https://img.shields.io/badge/Flakes-enabled-brightgreen)](flake.nix)
[![Last commit](https://img.shields.io/github/last-commit/AJThegamerOne/Nixos-Configeration)](https://github.com/AJThegamerOne/Nixos-Configeration/commits/main)
[![Stars](https://img.shields.io/github/stars/AJThegamerOne/Nixos-Configeration?style=social)](https://github.com/AJThegamerOne/Nixos-Configeration/stargazers)

[Features](#-features) · [Install](#-install) · [Everyday commands](#-everyday-commands) · [Repo layout](#-repo-layout) · [Notes](#-notes)

</div>

---

## ✨ Features

| Area | What's inside |
| --- | --- |
| 🧠 **Kernel** | CachyOS BORE, x86_64-v3, `ntsync`, tuned `vm.max_map_count`, zram swap — built for a Ryzen 7 5800X3D |
| 🖥️ **Desktop** | KDE Plasma 6 + SDDM, Wayland with XWayland fallback, KDE PIM removed, Wayland Ozone for Electron apps |
| 🎮 **Gaming** | Steam (Remote Play + firewall ports, Gamescope session), Gamemode, Gamescope `capSysNice`, MangoHud, Goverlay, Lutris, Faugus Launcher, ProtonPlus, Proton-GE |
| 🔊 **Audio** | PipeWire with Pulse/ALSA/JACK bridge, 32-bit ALSA, high-quality resampling, RTKit |
| 🧰 **Hardware** | AMD microcode, redistributable firmware, 32-bit graphics, Steam udev rules, Bluetooth, fwupd |
| 🌐 **Browsers** | Helium (with Chrome's Widevine CDM), Google Chrome, Zuno for YouTube Music |
| 💬 **Apps** | Discord with Vencord baked in via overlay, Ghostty, fastfetch, Git, Prism Launcher, Lunar Client, Zoom, OpenCode |
| 📦 **Extras** | Flatpak with Nightcap, Vice instant replay, `nix-index-database` for `comma`/`nix-locate`, `nix-ld` |
| ⌨️ **Terminal** | Ghostty on **TokyoNight Storm** with **Hack Nerd Font**; `fastfetch` launches automatically with every interactive shell |
| 🗂️ **Dotfiles** | Ready-to-copy fastfetch, Ghostty, Konsole, KDE Plasma (including the TokyoNight color scheme), and zsh configs in [`dotfiles/`](dotfiles/) |

Built declaratively with flakes: pinned inputs in [`flake.lock`](flake.lock), machine config in [`configuration.nix`](configuration.nix).

---

## 🚀 Install

1. Boot the NixOS installer, partition/mount your disks under `/mnt`, and generate hardware config:

   ```sh
   nixos-generate-config --root /mnt
   ```

2. Clone this repo and replace the machine-specific hardware config with your generated one:

   ```sh
   git clone https://github.com/AJThegamerOne/Nixos-Configeration.git /mnt/etc/nixos
   nixos-generate-config --root /mnt --show-hardware-config > /mnt/etc/nixos/hardware-configuration.nix
   ```

3. Edit [`configuration.nix`](configuration.nix):

   - `networking.hostName`
   - `time.timeZone`
   - user name / `initialPassword` (change after first login)
   - uncomment the NVIDIA section if you have an NVIDIA GPU

4. Install:

   ```sh
   nixos-install --flake /mnt/etc/nixos#nixos --accept-flake-config
   ```

   `--accept-flake-config` trusts the CachyOS kernel binary cache, so you don't compile a kernel.

5. Reboot, then change your password:

   ```sh
   passwd
   ```

6. Optional — restore the user dotfiles:

   ```sh
   cp -r dotfiles/fastfetch/* ~/.config/fastfetch/
   cp -r dotfiles/ghostty/* ~/.config/ghostty/
   mkdir -p ~/.local/share/konsole ~/.local/share/color-schemes
   cp dotfiles/konsole/* ~/.local/share/konsole/
   cp dotfiles/konsole/konsolerc ~/.config/konsolerc
   cp dotfiles/kde/k* dotfiles/kde/plasma* ~/.config/
   cp dotfiles/kde/color-schemes/TokyoNight.colors ~/.local/share/color-schemes/
   cp dotfiles/zshrc ~/.zshrc
   fc-cache -f
   kbuildsycoca6 --noincremental
   ```

---

## ⚡ Everyday commands

| Command | What it does |
| --- | --- |
| `nixos-update` | Update flake inputs and rebuild/switch in one go |
| `nixos-push "message"` | Stage, commit, and push changes to GitHub |
| `sudo nixos-rebuild switch --flake /etc/nixos#nixos` | Rebuild after editing config |

Manual equivalent of `nixos-update`:

```sh
sudo nix flake update --flake /etc/nixos
sudo nixos-rebuild switch --flake /etc/nixos#nixos
```

`nixos-push` uses your `gh auth login` session for authentication.

---

## 🗂️ Repo layout

```text
.
├── flake.nix                  # flake inputs and nixosConfigurations
├── flake.lock                 # pinned input revisions
├── configuration.nix          # the main system config
├── hardware-configuration.nix # generated disk/CPU config
├── pkgs/
│   ├── helium.nix             # Helium AppImage + Widevine CDM
│   └── zuno.nix               # Zuno AppImage
├── dotfiles/
│   ├── fastfetch/             # config + NixOS logo
│   ├── ghostty/               # TokyoNight Storm config
│   ├── konsole/               # Nerd Font profile
│   ├── kde/                   # Plasma config + TokyoNight color scheme
│   └── zshrc                  # fastfetch on shell startup
└── README.md
```

---

## 📝 Notes

- [`hardware-configuration.nix`](hardware-configuration.nix) was generated on the original machine — replace it before installing on different hardware.
- `system.stateVersion` is set once at install; don't change it afterwards.
- To update Helium, bump `version` and `hash` in [`pkgs/helium.nix`](pkgs/helium.nix). Get the hash with `nix hash convert --to sri <hex>` from the release asset digest.
- Helium's Widevine CDM is symlinked from nixpkgs `widevine-cdm` (the one Google Chrome uses).
- The CachyOS binary cache (`cache.lantian.pub/lantian`) is configured in `configuration.nix`.
- After adding/removing packages that provide `.desktop` files, refresh the KDE launcher cache with `kbuildsycoca6 --noincremental`.
- KDE dotfiles contain layout, themes, and shortcuts only — no wallet, mail, or SSH config is committed.

---

<div align="center">

Made with ❄️ NixOS · 🧡 KDE Plasma · 🎮 Proton

</div>
