# AJ's NixOS Config

Gaming-focused NixOS setup with the CachyOS kernel, KDE Plasma 6, and Steam/Proton essentials.

## What's included

- **CachyOS kernel (BORE, x86_64-v3)** via `xddxdd/nix-cachyos-kernel` with Lantian binary cache, tuned for Ryzen 5800X3D
- **KDE Plasma 6** + SDDM (GNOME swap commented in `configuration.nix`); KDE PIM (Kontact/KMail/Akonadi) disabled
- **Gaming**: Steam (Remote Play/firewall ports, Gamescope session), Gamemode, Gamescope (`capSysNice`), MangoHud, Goverlay, Lutris, Faugus Launcher, ProtonPlus, Proton-GE
- **Performance**: `ntsync` kernel module, `vm.max_map_count` tuned for Proton/Wine, zram swap
- **Audio**: PipeWire (Pulse/ALSA/JACK, 32-bit ALSA), higher-quality resampling, RTKit
- **Hardware**: AMD CPU microcode, redistributable firmware, 32-bit graphics, Steam hardware udev rules, Bluetooth, fwupd
- **QoL**: Nix flakes/command enabled, auto store optimise, weekly GC, `nix-ld`, Wayland Ozone for Electron apps
- **Apps**: Helium browser (with Google Chrome's Widevine CDM), Zuno (YouTube Music), Google Chrome, Discord (with Vencord baked in via overlay), Ghostty terminal, fastfetch, Git, Prism Launcher, Lunar Client, Zoom, OpenCode
- **Flatpak**: enabled, with Nightcap installed from its official bundle (`io.github.CoderDayton.nightcap`)
- **Terminal**: Ghostty with the TokyoNight Storm theme and Hack Nerd Font; `fastfetch` runs automatically on every interactive shell startup
- **Vice**: instant-replay clipper via upstream flake module
- **Dotfiles**: ready-to-copy user configs in `dotfiles/` (see below)

## Quick install

1. Boot the NixOS installer, partition/mount disks under `/mnt`, then generate hardware config:

   ```sh
   nixos-generate-config --root /mnt
   ```

2. Clone this repo onto the target, then replace the machine-specific hardware config with the one you just generated:

   ```sh
   git clone https://github.com/AJThegamerOne/Nixos-Configeration.git /mnt/etc/nixos
   nixos-generate-config --root /mnt --show-hardware-config > /mnt/etc/nixos/hardware-configuration.nix
   ```

3. Edit `configuration.nix`:
   - `networking.hostName`
   - `time.timeZone`
   - user name / `initialPassword` (change after first login with `passwd`)
   - uncomment NVIDIA section if you have an NVIDIA GPU

4. Install:

   ```sh
   nixos-install --flake /mnt/etc/nixos#nixos --accept-flake-config
   ```

   `--accept-flake-config` trusts the CachyOS kernel binary cache so you don't compile kernels.

5. Reboot. After first login, change your password:

   ```sh
   passwd
   ```

6. Optionally restore the user dotfiles:

   ```sh
   cp -r dotfiles/fastfetch/* ~/.config/fastfetch/
   cp -r dotfiles/ghostty/* ~/.config/ghostty/
   mkdir -p ~/.local/share/konsole
   cp dotfiles/konsole/* ~/.local/share/konsole/
   cp dotfiles/konsole/konsolerc ~/.config/konsolerc
   cp dotfiles/zshrc ~/.zshrc
   fc-cache -f
   ```

## Rebuild / update

Rebuild after editing config:

```sh
sudo nixos-rebuild switch --flake /etc/nixos#nixos
```

Update flake inputs and rebuild in one command:

```sh
nixos-update
```

Or manually:

```sh
sudo nix flake update --flake /etc/nixos
sudo nixos-rebuild switch --flake /etc/nixos#nixos
```

## Push changes to GitHub

After editing files under `/etc/nixos`, commit and push in one step:

```sh
nixos-push "describe your change"
```

It stages all changes, commits them, and pushes `main` to GitHub using your `gh auth login` session.

## Notes

- `hardware-configuration.nix` in this repo is from the original machine — replace it with your generated one before installing on different hardware.
- `system.stateVersion` is set once at install; do not change it afterwards.
- To update Helium, bump `version` and `hash` in `pkgs/helium.nix` (get hash from release asset digest: `nix hash convert --to sri <hex>`).
- Helium's Widevine CDM is symlinked from the nixpkgs `widevine-cdm` used by Google Chrome in `pkgs/helium.nix`.
- The CachyOS kernel binary cache (`cache.lantian.pub/lantian`) is configured in `configuration.nix`.
- After adding/removing system packages that provide `.desktop` files, refresh the KDE launcher cache with `kbuildsycoca6 --noincremental`.
