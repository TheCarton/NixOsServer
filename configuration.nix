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

  services.resolved.enable = true; # the wiki says this is needed for mullvad.

  # Enable the Flakes feature and the accompanying new nix command-line tool
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  networking.firewall = {
    allowedTCPPorts = [
      8096
      8920 # Web frontend
      80
      443
      8989
      9091
      51820
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

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    nftables
    systemctl-tui
    firejail
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
    "lg" = "lazygit";
    rebuild = "nh os switch";
    etc = "cd /etc/nixos";
  };
}
