<div align="center">

# AJ's NixOS Config

**Gaming-first NixOS desktop — CachyOS kernel, KDE Plasma 6, and a carefully tuned Steam/Proton stack.**

[![NixOS](https://img.shields.io/badge/OS-NixOS-7BAFDE?logo=nixos&logoColor=white)](https://nixos.org)
[![KDE Plasma](https://img.shields.io/badge/Desktop-Plasma%206-1E97E0?logo=kde&logoColor=white)](https://plasma.kde.org)
[![Kernel](https://img.shields.io/badge/Kernel-CachyOS%20BORE-orange)](https://github.com/xddxdd/nix-cachyos-kernel)
[![Flakes](https://img.shields.io/badge/Flakes-enabled-brightgreen)](flake.nix)
[![Last commit](https://img.shields.io/github/last-commit/AJThegamerOne/Nixos-Configeration)](https://github.com/AJThegamerOne/Nixos-Configeration/commits/main)
[![Stars](https://img.shields.io/github/stars/AJThegamerOne/Nixos-Configeration?style=social)](https://github.com/AJThegamerOne/Nixos-Configeration/stargazers)

[Features](#-features) · [Clean install](#-clean-install) · [Dotfiles](#-dotfiles) · [Move to a new machine](#-move-to-a-new-machine) · [Everyday commands](#-everyday-commands) · [Repo layout](#-repo-layout) · [Notes](#-notes)

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
| 🗂️ **Dotfiles** | fastfetch, Ghostty, Konsole, KDE Plasma (incl. TokyoNight color scheme) and zsh configs — installed with one script |

Built declaratively with flakes: pinned inputs in [`flake.lock`](flake.lock), machine config in [`configuration.nix`](configuration.nix).

---

## 🚀 Clean install

> What you need: a NixOS installer USB, an internet connection, and a disk you're happy to wipe.

### 1. Boot the installer and mount your disks

Partition and mount your target disks under `/mnt`. For the reference UEFI + Btrfs layout:

```sh
mount /dev/disk/by-uuid/YOUR-ROOT-UUID /mnt
mount /dev/disk/by-uuid/YOUR-BOOT-UUID /mnt/boot
mount -o subvol=nix /dev/disk/by-uuid/YOUR-ROOT-UUID /mnt/nix
mount -o subvol=home /dev/disk/by-uuid/YOUR-ROOT-UUID /mnt/home
swapon /dev/disk/by-uuid/YOUR-SWAP-UUID   # if using a swap partition
```

### 2. Generate a hardware config for this machine

```sh
nixos-generate-config --root /mnt
```

This writes `/mnt/etc/nixos/hardware-configuration.nix` — it detects disks, CPU microcode and kernel modules.

### 3. Clone this repo into `/mnt/etc/nixos`

```sh
mkdir -p /mnt/etc
git clone https://github.com/AJThegamerOne/Nixos-Configeration.git /mnt/etc/nixos
```

### 4. Replace the placeholder hardware config

The repo's `hardware-configuration.nix` was generated on a different machine. Overwrite it with yours from step 2:

```sh
nixos-generate-config --root /mnt --show-hardware-config > /mnt/etc/nixos/hardware-configuration.nix
```

### 5. Review the system config

```sh
nano /mnt/etc/nixos/configuration.nix
```

Change at minimum:

- `networking.hostName` — your machine name
- `time.timeZone` — e.g. `Australia/Sydney`
- `i18n.defaultLocale` — e.g. `en_AU.UTF-8`
- user name / `initialPassword`
- uncomment the NVIDIA block **only** if you have an NVIDIA GPU

Everything else is ready as-is.

### 6. Install

```sh
nixos-install --flake /mnt/etc/nixos#nixos --accept-flake-config
```

`--accept-flake-config` is important: it trusts the CachyOS binary cache so the kernel is downloaded, not compiled.

### 7. Reboot and set your password

```sh
reboot
# after login:
passwd
```

### 8. Install the user dotfiles

From the cloned repo (now at `/etc/nixos`):

```sh
cd /etc/nixos
./install.sh
```

This copies your fastfetch, Ghostty, Konsole, KDE Plasma and zsh configs into `$HOME`, backs up anything it replaces, and refreshes the font/KDE caches. See [Dotfiles](#-dotfiles).

### 9. Verify

Open a new Ghostty window — you should see the TokyoNight Storm theme, Nerd Font icons, and `fastfetch` on startup. Check with:

```sh
fastfetch
gh auth status
```

---

## 🗂️ Dotfiles

[`install.sh`](install.sh) is the one-command way to move your user config onto any NixOS install.

```sh
./install.sh          # install everything
./install.sh --help   # show what it does
```

| Source in repo | Destination |
| --- | --- |
| `dotfiles/fastfetch/config.jsonc` + logo | `~/.config/fastfetch/` |
| `dotfiles/ghostty/config` | `~/.config/ghostty/config` |
| `dotfiles/konsole/NerdFont.profile` | `~/.local/share/konsole/` |
| `dotfiles/konsole/konsolerc` | `~/.config/konsolerc` |
| `dotfiles/kde/*` | `~/.config/` |
| `dotfiles/kde/color-schemes/TokyoNight.colors` | `~/.local/share/color-schemes/` |
| `dotfiles/zshrc` | `~/.zshrc` |

Existing files are saved as `<file>.bak.<timestamp>` before being replaced. After copying, the script runs `fc-cache -f` and `kbuildsycoca6 --noincremental` so fonts and the KDE launcher pick everything up immediately.

> The KDE files contain layout, themes and shortcuts only — no wallet, mail or SSH config is committed.

---

## 🔄 Move to a new machine

1. **On the old machine**, push your latest system config:
   ```sh
   nixos-push "describe what changed"
   ```
2. If you tweaked user configs, copy them into the repo first:
   ```sh
   cp ~/.config/fastfetch/config.jsonc /etc/nixos/dotfiles/fastfetch/
   cp ~/.config/ghostty/config /etc/nixos/dotfiles/ghostty/
   cp ~/.config/konsolerc /etc/nixos/dotfiles/konsole/
   cp ~/.config/k* ~/.config/plasma* /etc/nixos/dotfiles/kde/
   cp ~/.local/share/color-schemes/TokyoNight.colors /etc/nixos/dotfiles/kde/color-schemes/
   cp ~/.zshrc /etc/nixos/dotfiles/
   nixos-push "sync dotfiles"
   ```
3. **On the new machine**, follow [Clean install](#-clean-install), then run `./install.sh`.
4. Log in with GitHub CLI once so `nixos-push` works there:
   ```sh
   gh auth login
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
├── install.sh                 # installs all user dotfiles into $HOME
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

- [`hardware-configuration.nix`](hardware-configuration.nix) was generated on the original machine — step 4 replaces it.
- `system.stateVersion` is set once at install; don't change it afterwards.
- To update Helium, bump `version` and `hash` in [`pkgs/helium.nix`](pkgs/helium.nix). Get the hash with `nix hash convert --to sri <hex>` from the release asset digest.
- Helium's Widevine CDM is symlinked from nixpkgs `widevine-cdm` (the one Google Chrome uses).
- The CachyOS binary cache (`cache.lantian.pub/lantian`) is configured in `configuration.nix`.
- After adding/removing packages that provide `.desktop` files, refresh the KDE launcher cache with `kbuildsycoca6 --noincremental`.

---

<div align="center">

Made with ❄️ NixOS · 🧡 KDE Plasma · 🎮 Proton

</div>
