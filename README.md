# AJ's NixOS Config

Gaming-focused NixOS setup with the CachyOS kernel, KDE Plasma 6, and Steam/Proton essentials.

## What's included

- **CachyOS kernel (BORE)** via `xddxdd/nix-cachyos-kernel` with Lantian binary cache
- **KDE Plasma 6** + SDDM (GNOME swap commented in `configuration.nix`)
- **Gaming**: Steam (Remote Play/firewall ports, Gamescope session), Gamemode, Gamescope (`capSysNice`), MangoHud, Goverlay, Lutris, Faugus Launcher, ProtonPlus, Proton-GE
- **Performance**: `ntsync` kernel module, `vm.max_map_count` tuned for Proton/Wine
- **Hardware**: AMD CPU microcode, redistributable firmware, 32-bit graphics, Steam hardware udev rules
- **Apps**: Helium browser, Discord, Prism Launcher, Lunar Client, Zoom
- **Vice**: instant-replay clipper via upstream flake module

## Quick install

1. Boot the NixOS installer, partition/mount disks under `/mnt`, then generate hardware config:

   ```sh
   nixos-generate-config --root /mnt
   ```

2. Clone this repo onto the target, then replace the placeholder hardware config with the one you just generated:

   ```sh
   git clone https://github.com/AJThegamerOne/Nixos-Configeration.git /mnt/etc/nixos
   cp /mnt/etc/nixos/hardware-configuration.nix /mnt/etc/nixos/hardware-configuration.nix.placeholder
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

## Rebuild / update

```sh
sudo nixos-rebuild switch --flake /etc/nixos#nixos
```

Update inputs:

```sh
nix flake update
sudo nixos-rebuild switch --flake /etc/nixos#nixos
```

## Notes

- `hardware-configuration.nix` in this repo is a **placeholder** - replace it with your generated one before installing.
- `system.stateVersion` is set once at install; do not change it afterwards.
- To update Helium, bump `version` and `hash` in `pkgs/helium.nix` (get hash from release asset digest: `nix hash convert --to sri <hex>`).
- The CachyOS kernel binary cache (`cache.lantian.pub/lantian`) is configured in `configuration.nix`.
