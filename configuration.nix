{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  security.polkit.enable = true;

  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "modesetting" ];

  # 1. enable vaapi on OS-level
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver # previously vaapiIntel
      vaapiVdpau
      intel-compute-runtime # OpenCL filter support (hardware tonemapping and subtitle burn-in)
      onevpl-intel-gpu
      intel-media-sdk # QSV up to 11th gen
    ];
  };

  environment.sessionVariables = {
    # define flake directory for nh (from vimjoyer vid)
    FLAKE = "/etc/nixos";
  };

  # Enable the Flakes feature and the accompanying new nix command-line tool
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  services.jellyseerr = {
    enable = true;
    port = 5055;
    openFirewall = true;
  };

  virtualisation.docker.enable = true;

  # never sleep
  powerManagement.powertop.enable = true;
  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };

  networking.firewall = {
    allowedTCPPorts = [
      8096
      8920 # Web frontend
      80
      443
      9091
      51820
      51413
      9696 # Prowlarr
      8989 # Sonarr Vanilla
      8990 # Sonarr Anime
      7878 # Radarr
      7879 # Radarr
      5055 # Jellyseerr
      8080 # SABnzbd
      6767 # Bazarr
    ];

    allowedUDPPorts = [
      51413
      1900
      7359 # Discovery
    ];
  };

  services.nginx = {
    enable = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts = {
      "www.cartonofdoom.win" = {
        forceSSL = true;
        enableACME = true;
        # All serverAliases will be added as extra domain names on the certificate.
        serverAliases = [ "cartonofdoom.win" ];
        locations."/" = {
          proxyPass = "http://localhost:8096";
        };
        extraConfig = ''
          ## The default `client_max_body_size` is 1M, this might not be enough for some posters, etc.
          client_max_body_size 20M;
            
          # Security / XSS Mitigation Headers
          # NOTE: X-Frame-Options may cause issues with the webOS app
          add_header X-Frame-Options \"SAMEORIGIN\";
          add_header X-Content-Type-Options \"nosniff\";
        '';
      };

      "jellyseerr.cartonofdoom.win" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:5055";
        };
      };
    };
  };

  security.acme.defaults.email = "theukearchy@gmail.com";
  security.acme.acceptTerms = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.admin = {
    isNormalUser = true;
    description = "Admin";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    onevpl-intel-gpu
    intel-gpu-tools
    docker-compose
    nftables
    systemctl-tui
    firejail
    openssl
    wget
    tmux
    certbot
    wormhole-rs
    helix
    nil
    _1password-gui
    nh
    nix-output-monitor
    git
    btop

    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
    nginx
  ];

  environment.variables.EDITOR = "hx";

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    user = "admin";
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      X11Forwarding = true;
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
  programs.bash.shellAliases = {
    rebuild = "nh os switch";
    etc = "cd /etc/nixos";
    cddocker = "cd /etc/dockerfiles";
  };
}
