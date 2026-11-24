{
  description = "AJ's NixOS config - gaming setup with the CachyOS kernel";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # CachyOS kernels. The `release` branch tracks kernels that are already
    # built in the author's binary cache (fast installs, no compiling).
    # Do NOT override its nixpkgs input - patches must match the kernel version.
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    # Vice - instant-replay game clipper (Medal.tv alternative)
    vice = {
      url = "github:eklonofficial/Vice";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Prebuilt nix-index database for comma/nix-locate
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-cachyos-kernel, vice, nix-index-database, ... }@inputs: {
    # Build/install with:  nixos-rebuild switch --flake .#nixos
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix

        # Exposes the CachyOS kernels as pkgs.cachyosKernels.*
        # `pinned` uses the exact nixpkgs revision the cached kernels were
        # built with, so you get binary-cache hits instead of compiling.
        { nixpkgs.overlays = [ nix-cachyos-kernel.overlays.pinned ]; }

        # Adds the services.vice.* options (enabled in configuration.nix)
        vice.nixosModules.default

        # Prebuilt nix-index DB for comma (` , <cmd>`) and nix-locate
        nix-index-database.nixosModules.nix-index
      ];
    };
  };
}
