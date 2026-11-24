{ config, pkgs, lib, inputs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # --- Boot (UEFI) -----------------------------------------------------------
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.supportedFilesystems = [ "ntfs" ]; # NTFS3 support

  # CachyOS BORE kernel, x86_64-v3 optimized for Ryzen 5800X3D (Zen 3).
  # Other variants from the flake, e.g.:
  #   linuxPackages-cachyos-bore            (BORE scheduler, generic x86_64)
  #   linuxPackages-cachyos-latest          (latest mainline, EEVDF)
  #   linuxPackages-cachyos-lts             (LTS)
  #   linuxPackages-cachyos-bore-lto-x86_64-v3  (Clang + ThinLTO, may take longer if uncached)
  # Full list: https://github.com/xddxdd/nix-cachyos-kernel
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-x86_64-v3;
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
    jack.enable = true;
    extraConfig.pipewire."10-audio-quality" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.allowed-rates" = [ 44100 48000 88200 96000 ];
      };
      "stream.properties" = {
        "resample.quality" = 10;
      };
    };
  };

  # --- CPU / Graphics ----------------------------------------------------------
  hardware.cpu.amd.updateMicrocode = true; # Ryzen 7 5800X3D
  hardware.enableRedistributableFirmware = true; # extra firmware blobs (Wi-Fi/BT/etc.)

  # AMD GPU (RX 9060 XT): mesa/RADV drivers are included automatically,
  # nothing extra needed. The NVIDIA section below stays commented out.
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # 32-bit Vulkan/OpenGL for Steam/Proton games
    extraPackages = with pkgs; [
      libva
      libvdpau-va-gl
    ];
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
    auto-optimise-store = true;
    substituters = [
      "https://cache.nixos.org"
      "https://cache.lantian.pub/lantian" # prebuilt CachyOS kernels
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "lantian:WVGO7vsRMSEN+h7Lp7kv6SAmrkEXgUGbbXm7jMDjBuQ="
    ];
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # --- System QoL -------------------------------------------------------------
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.bluetooth.settings.General.Experimental = true; # better BT codec/device compatibility
  services.fwupd.enable = true;
  zramSwap.enable = true;
  programs.nix-ld.enable = true; # run unpackaged binaries more easily
  programs.appimage = {
    enable = true;
    binfmt = true;
  };
  programs.obs-studio.enable = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1"; # Wayland-native Electron apps where supported

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
    (callPackage ./pkgs/zuno.nix { }) # Zuno YouTube Music desktop client (official AppImage)
    discord
    prismlauncher # Minecraft
    lunar-client # Minecraft PvP client
    protonplus # Proton-GE / Wine-GE manager
    mangohud # FPS/frame-time overlay for Vulkan/OpenGL games
    goverlay # GUI for MangoHud/GameMode/vkBasalt config
    opencode # AI coding agent
    zoom-us
  ];

  # Set once at install time; do not change after installing.
  system.stateVersion = "26.11";
}
