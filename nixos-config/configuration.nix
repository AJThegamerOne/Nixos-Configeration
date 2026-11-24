{ config, pkgs, lib, inputs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # --- Boot (UEFI) -----------------------------------------------------------
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # CachyOS kernel with the BORE scheduler (same as CachyOS's default kernel).
  # Other variants from the flake, e.g.:
  #   linuxPackages-cachyos-latest          (latest mainline, EEVDF)
  #   linuxPackages-cachyos-lts             (LTS)
  #   linuxPackages-cachyos-bore-lto        (Clang + ThinLTO)
  #   linuxPackages-cachyos-bore-lto-x86_64-v3  (CPU-optimized, needs a modern CPU)
  # Full list: https://github.com/xddxdd/nix-cachyos-kernel
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore;
  boot.kernelModules = [ "ntsync" ]; # Wine/Proton NT synchronization (faster Windows games)

  # Gaming/performance tuning
  boot.kernel.sysctl."vm.max_map_count" = 2147483642; # Proton/Wine/esync games need high map count

  # --- Networking ------------------------------------------------------------
  networking.hostName = "nixos"; # pick your hostname
  networking.networkmanager.enable = true;

  # --- Locale ----------------------------------------------------------------
  # time.timeZone = "America/New_York"; # set your timezone
  i18n.defaultLocale = "en_US.UTF-8";

  # --- Desktop: KDE Plasma 6 (CachyOS's default) ------------------------------
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  # Prefer GNOME? Comment the two lines above and uncomment these:
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;

  # --- Sound (PipeWire) -------------------------------------------------------
  security.rtkit.enable = true;
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # --- CPU / Graphics ----------------------------------------------------------
  hardware.cpu.amd.updateMicrocode = true; # Ryzen 7 5800X3D
  hardware.enableRedistributableFirmware = true; # extra firmware blobs (Wi-Fi/BT/etc.)

  # AMD GPU (RX 9060 XT): mesa/RADV drivers are included automatically,
  # nothing extra needed. The NVIDIA section below stays commented out.
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # 32-bit Vulkan/OpenGL for Steam/Proton games
  };
  hardware.steam-hardware.enable = true; # udev rules for Steam controllers/VR devices
  # NVIDIA GPU? Uncomment (open module works on Turing / RTX 20xx and newer):
  # services.xserver.videoDrivers = [ "nvidia" ];
  # hardware.nvidia = {
  #   modesetting.enable = true;
  #   open = true;
  #   package = config.boot.kernelPackages.nvidiaPackages.latest;
  # };

  # --- User --------------------------------------------------------------------
  users.users.aj = {
    isNormalUser = true;
    description = "AJ";
    extraGroups = [ "networkmanager" "wheel" "video" "input" ];
    initialPassword = "changeme"; # change after first login: passwd
  };

  # --- Nix settings -------------------------------------------------------------
  nixpkgs.config.allowUnfree = true; # steam, discord, lunar-client, zoom

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [
      "https://cache.nixos.org"
      "https://cache.lantian.pub/lantian" # prebuilt CachyOS kernels
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "lantian:WVGO7vsRMSEN+h7Lp7kv6SAmrkEXgUGbbXm7jMDjBuQ="
    ];
  };

  # --- Gaming ---------------------------------------------------------------------
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # open ports for Steam Remote Play
    dedicatedServer.openFirewall = true; # open ports for Source Dedicated Server
    gamescopeSession.enable = true; # optional "SteamOS-like" gamescope session
  };
  programs.gamescope = {
    enable = true;
    capSysNice = true; # lets gamescope request higher priority for smoother frame pacing
  };
  programs.gamemode.enable = true;

  # Vice instant-replay clipper: package + daemon + udev rules + gsr wrapper
  services.vice.enable = true;

  environment.systemPackages = with pkgs; [
    lutris
    faugus-launcher # Windows games via UMU-Launcher
    (callPackage ./pkgs/helium.nix { }) # Helium browser (official AppImage)
    discord
    prismlauncher # Minecraft
    lunar-client # Minecraft PvP client
    protonplus # Proton-GE / Wine-GE manager
    mangohud # FPS/frame-time overlay for Vulkan/OpenGL games
    goverlay # GUI for MangoHud/GameMode/vkBasalt config
    zoom-us
  ];

  # Set once at install time; do not change after installing.
  system.stateVersion = "26.05";
}
