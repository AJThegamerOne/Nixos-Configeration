{ config, pkgs, lib, inputs, ... }:

{
  # Quick map:
  # - Boot/kernel: boot.*
  # - Networking/locale: networking.*, i18n.*, time.*
  # - Desktop/audio: services.xserver.*, services.desktopManager.*, services.pipewire.*
  # - Hardware/GPU: hardware.*
  # - User/Nix: users.users.*, nix.*
  # - Gaming/apps: programs.steam/gamescope/gamemode, environment.systemPackages
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
  # Workaround for amdgpu/DC advertising DRM_FORMAT_RGBA8888 (RA24) but rejecting it,
  # which causes KWin/SDDM Wayland modeset loops on affected AMD GPUs (e.g. RX 9060 XT).
  # Upstream tracking: https://gitlab.freedesktop.org/drm/amd/-/work_items/5339
  # temp workaround, might remove this later if it gets fixed upstream
  boot.kernelPatches = [
    {
      name = "amdgpu-ra24-fix";
      patch = ./patches/amdgpu-ra24-fix.patch;
    }
  ];
  boot.kernelModules = [ "ntsync" ]; # Wine/Proton NT synchronization (faster Windows games)

  # Gaming/performance tuning
  boot.kernel.sysctl."vm.max_map_count" = 2147483642; # Proton/Wine/esync games need high map count

  # --- Networking ------------------------------------------------------------
  networking.hostName = "aj"; # pick your hostname
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;

  # DNS over TLS (Quad9)
  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNSSEC = "true";
      DNSOverTLS = "true";
      MulticastDNS = "false";
      FallbackDNS = [ "9.9.9.9" "149.112.112.112" ];
    };
  };
  networking.nameservers = [ "9.9.9.9#dns.quad9.net" "149.112.112.112#dns.quad9.net" ];

  # --- Locale ----------------------------------------------------------------
  time.timeZone = "Australia/Sydney"; # set your timezone
  i18n.defaultLocale = "en_AU.UTF-8";
  # --- Desktop: KDE Plasma 6 (CachyOS's default) ------------------------------
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  # Remove the KDE PIM suite (Kontact, KMail, Akonadi, etc.)
  programs.kde-pim.enable = false;
  programs.xwayland.enable = true; # X11 app compatibility on Wayland
  # Prefer GNOME? Comment the two lines above and uncomment these:
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;

  # --- Sound (PipeWire) -------------------------------------------------------
  security.rtkit.enable = true;
  security.apparmor.enable = true;
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
    shell = pkgs.zsh;
  };

  # --- Shell -------------------------------------------------------------------
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    interactiveShellInit = ''
      # Friendly nix wrappers (pacman/paru-like shortcuts)
      nix() {
        if [[ "$1" == "search" ]]; then
          shift
          if [[ $# -eq 0 ]]; then
            command nix search --help
            return 1
          fi
          # default to nixpkgs when no flake ref is given
          if [[ "$1" == "nixpkgs" || "$1" == *"#"* || "$1" == *":"* || "$1" == .* || "$1" == /* ]]; then
            command nix search "$@"
          else
            command nix search nixpkgs "$@"
          fi
        elif [[ "$1" == "install" ]]; then
          shift
          if [[ $# -eq 0 ]]; then
            echo "Usage: nix install <pkg> [<pkg>...]"
            return 1
          fi
          local pkgs=()
          for p in "$@"; do
            if [[ "$p" == *"#"* || "$p" == *":"* ]]; then
              pkgs+=("$p")
            else
              pkgs+=("nixpkgs#$p")
            fi
          done
          command nix profile install "''${pkgs[@]}"
        else
          command nix "$@"
        fi
      }
    '';
  };
  programs.starship.enable = true;

  # --- Nix settings -------------------------------------------------------------
  nixpkgs.config.allowUnfree = true; # steam, discord, lunar-client, zoom

  # Flatpak (Nightcap is installed from its official Flatpak bundle).
  services.flatpak.enable = true;

  # Vencord for Discord (NixOS-native: the store copy is read-only, so the
  # official installer cannot patch it in place).
  nixpkgs.overlays = [
    (final: prev: {
      discord = prev.discord.override { withVencord = true; };
    })
  ];

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
  services.fstrim.enable = true; # periodic TRIM for SSD/NVMe
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };
  systemd.oomd.enable = true; # better behavior under memory pressure
  services.journald.settings.Journal = {
    SystemMaxUse = "1G";
    MaxRetentionSec = "1month";
  };
  programs.nix-ld.enable = true; # run unpackaged binaries more easily
  programs.appimage = {
    enable = true;
    binfmt = true;
  };
  programs.obs-studio.enable = true;
  programs.nix-index-database.comma.enable = true; # `, cmd` runs missing commands from nixpkgs
  programs.command-not-found.enable = false;
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
    fastfetch # CLI system info
    discord
    prismlauncher # Minecraft
    lunar-client # Minecraft PvP client
    protonplus # Proton-GE / Wine-GE manager
    mangohud # FPS/frame-time overlay for Vulkan/OpenGL games
    goverlay # GUI for MangoHud/GameMode/vkBasalt config
    opencode # AI coding agent
    zoom-us
    git # version control (git clone, etc.)
    gh # GitHub CLI (authenticate pushes to GitHub)
    google-chrome # Google Chrome browser
    ghostty # GPU-accelerated terminal
    (nerd-fonts.hack) # Nerd Font for terminal icons (fastfetch, starship)

    # One-command system update: refresh flake inputs and rebuild.
    (writeShellScriptBin "nixos-update" ''
      set -e
      echo "==> Updating NixOS flake inputs..."
      sudo nix flake update --flake /etc/nixos
      echo "==> Rebuilding and switching..."
      sudo nixos-rebuild switch --flake /etc/nixos#nixos
      echo "==> Done. NixOS is up to date."
    '')
    (writeShellScriptBin "nixos-push" ''
      set -e
      if [ $# -eq 0 ]; then
        echo "Usage: nixos-push <commit message>"
        exit 1
      fi
      cd /etc/nixos
      echo "==> Staging changes..."
      sudo git add -A
      if git diff --cached --quiet; then
        echo "==> Nothing to commit."
      else
        echo "==> Committing..."
        sudo git commit -m "$*"
      fi
      echo "==> Pushing to GitHub..."
      token=$(gh auth token)
      sudo env GH_TOKEN="$token" git push origin main
      echo "==> Done. GitHub is up to date."
    '')
  ];

  # Set once at install time; do not change after installing.
  system.stateVersion = "26.11";
}
