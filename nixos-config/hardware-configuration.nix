# ============================================================================
# PLACEHOLDER - REPLACE THIS FILE DURING INSTALLATION!
#
# After partitioning and mounting your disks in the NixOS installer, run:
#   nixos-generate-config --root /mnt
# then copy the generated file over this one:
#   cp /mnt/etc/nixos/hardware-configuration.nix ~/nixos-config/hardware-configuration.nix
#
# The tmpfs root below only exists so the flake evaluates before installation.
# It is NOT a real hardware configuration and will not boot anything.
# ============================================================================
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "tmpfs";
    fsType = "tmpfs";
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
