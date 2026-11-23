# AJ's NixOS config

Gaming-focused NixOS configuration, ready to install.

## What's included

| App | How |
|---|---|
| Steam | `programs.steam.enable` (+ gamescope session, gamemode) |
| Lutris | nixpkgs |
| Faugus Launcher | nixpkgs (`faugus-launcher`) |
| Helium browser | official AppImage packaged in `pkgs/helium.nix` |
| Discord | nixpkgs |
| Vice clipper | upstream flake module, `services.vice.enable` |
| CachyOS kernel | `github:xddxdd/nix-cachyos-kernel/release`, BORE scheduler, prebuilt binary cache |
| Prism Launcher | nixpkgs |
| Lunar Client | nixpkgs (`lunar-client`) |
| ProtonPlus | nixpkgs |
| Zoom | nixpkgs (`zoom-us`) |

Desktop: KDE Plasma 6 (GNOME swap is commented in `configuration.nix`).

## Installing NixOS with this config

1. Boot the NixOS installer, partition and mount your disks under `/mnt`
   (see the NixOS manual if needed), then generate the hardware config:

   ```sh
   nixos-generate-config --root /mnt
   ```

2. Copy this repo onto the target and **replace the placeholder hardware config**:

   ```sh
   cp -r ~/nixos-config /mnt/etc/nixos-config
   cp /mnt/etc/nixos/hardware-configuration.nix /mnt/etc/nixos-config/hardware-configuration.nix
   ```

3. Edit `/mnt/etc/nixos-config/configuration.nix`:
   - `networking.hostName`
   - `time.timeZone`
   - user name / `initialPassword`
   - uncomment the NVIDIA section if you have an NVIDIA GPU

4. Install (flakes are enabled by the installer's `nix-command` support;
   `--accept-flake-config` trusts the CachyOS kernel binary cache):

   ```sh
   nixos-install --flake /mnt/etc/nixos-config#nixos --accept-flake-config
   ```

5. Reboot. Afterwards, rebuild any time with:

   ```sh
   sudo nixos-rebuild switch --flake /etc/nixos-config#nixos
   ```

## Updating

```sh
nix flake update        # bump nixpkgs, kernel, vice
sudo nixos-rebuild switch --flake .#nixos
```

To update Helium, bump `version` + `hash` in `pkgs/helium.nix` (grab the new
sha256 from the release's asset digest, `nix hash convert --to sri <hex>`).

## Notes

- The kernel binary cache (`cache.lantian.pub`) is configured in
  `configuration.nix`. On a fresh install, apply once before switching kernels
  if you ever change `boot.kernelPackages` to a non-cached variant.
- `hardware-configuration.nix` in this repo is a **placeholder** so the flake
  evaluates; it must be replaced with your generated one (step 2).
- `system.stateVersion` is set once at install; never change it afterwards.
