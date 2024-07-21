# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  security.polkit.enable = true;

  environment.sessionVariables = {
    # define flake directory for nh (from vimjoyer vid)
    FLAKE = "/etc/nixos";
  };

  # Enable the Flakes feature and the accompanying new nix command-line tool
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  services.sonarr = {
    enable = true;
    openFirewall = true;
    user = "admin";
    group = "media";
    dataDir = "/home/admin/JellyfinMedia/shows";
  };

  networking.firewall = {
    allowedTCPPorts = [
      8096
      8920 # Web frontend
      80
      443
      8989
      9091
    ];

    allowedUDPPorts = [
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

    virtualHosts."www.cartonofdoom.win" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://localhost:8096";
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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;

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
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  services.transmission = {
    enable = true; # Enable transmission daemon
    openRPCPort = true; # Open firewall for RPC
    settings = {
      # Override default settings
      rpc-bind-address = "0.0.0.0"; # Bind to own IP
      rpc-whitelist = "127.0.0.1,192.168.0.129"; # Whitelist your remote machine (10.0.0.1 in this example)
    };
  };
  services.mullvad-vpn.enable = true;

  environment.systemPackages = with pkgs; [
    mullvad
    sonarr
    transmission-qt
    openssl
    wget
    tmux
    certbot
    wormhole-rs
    helix
    lazygit
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

  environment.variables.EDITOR = "helix";

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    user = "admin";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

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
    "lg" = "lazygit";
    rebuild = "nh os switch";
    etc = "cd /etc/nixos";
  };
}
