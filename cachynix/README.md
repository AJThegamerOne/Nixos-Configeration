# CachyNix

Use this branch when you’re on CachyOS/Arch/another distro but want a similar setup to this NixOS config.

## Option 1: Nix package manager (closest parity)

Install Nix on your distro, then use flakes/home-manager or `nix profile` for packages that are identical across distros.

```sh
# Nix installer (official)
sh <(curl -L https://nixos.org/nix/install) --daemon

# Enable flakes
mkdir -p ~/.config/nix
printf "experimental-features = nix-command flakes\n" >> ~/.config/nix/nix.conf
```

Then install packages declaratively from a flake/home-manager config, or ad-hoc:

```sh
nix profile install nixpkgs#brave nixpkgs#gnutar nixpkgs#steam-run nixpkgs#amnezia-vpn nixpkgs#fastfetch nixpkgs#git nixpkgs#gh nixpkgs#ghostty
```

## Option 2: Native Arch/CachyOS packages

See `install-arch.sh` for a best-effort native package mapping. Names may differ across distros/AUR helpers.

## Notes

- NixOS-only bits (`programs.*`, systemd services, declarative system config) don’t map 1:1 to other distros.
- Prefer the Nix option for packages you want identical to the NixOS setup.
- Review before running scripts.
