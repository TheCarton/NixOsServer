{
  config,
  pkgs,
  nixpkgs-unstable,
  lib,
  ...
}:
let
  unstable = import nixpkgs-unstable {
    system = pkgs.system;
    config = {
      allowUnfree = true;
    };
  };
in

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # installed software
  environment.systemPackages = with pkgs; [
    cfssl # Cloudflare for Copyparty.
    certmgr # I think this took care of a warning message about not being able to access cfssl from Copyparty.
    nvtopPackages.nvidia
    dysk
    ripgrep
    hugo
    dua
    vpl-gpu-rt
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
    nginx
  ];

  security.polkit.enable = true;

  services.copyparty = {
    enable = true;
    # the user to run the service as
    user = "copyparty";
    # the group to run the service as
    group = "copyparty";
    # directly maps to values in the [global] section of the copyparty config.
    # see `copyparty --help` for available options
    settings = {

      i = "unix:770:www:/dev/shm/party.sock";
      # # use lists to set multiple values
      # p = [
      #   3210
      #   3211
      # ];
      # use booleans to set binary flags
      no-reload = false;
      # using 'false' will do nothing and omit the value when generating a config
      ignored-flag = false;
      # xff-hdr = "cf-connecting-ip";
      xff-src = "lan";
      rproxy = 1;
    };

    # create users
    accounts = {
      # specify user and password file
      luke.passwordFile = "/run/keys/copyparty/luke_password";
      aaron.passwordFile = "/run/keys/copyparty/aaron_password";
      rye.passwordFile = "/run/keys/copyparty/rye_password";
      pg.passwordFile = "/run/keys/copyparty/pg_password";
    };

    # create a group
    groups = {
      g1 = [
        "luke"
      ];
    };

    # create a volume
    volumes = {
      # create a volume at "/" (the webroot), which will
      "/" = {
        # share the contents of "/srv/copyparty"
        path = "/hdd/data/copyparty";
        # see `copyparty --help-accounts` for available options
        access = {
          # users get read-write
          rw = [
            "luke"
            "aaron"
            "rye"
            "pg"
          ];
        };
        # see `copyparty --help-flags` for available options
        flags = {
          # "fk" enables filekeys (necessary for upget permission) (4 chars long)
          fk = 4;
          # scan for new files every 60sec
          scan = 60;
          # volflag "e2d" enables the uploads database
          e2d = true;
          # "d2t" disables multimedia parsers (in case the uploads are malicious)
          d2t = true;
          # skips hashing file contents if path matches *.iso
          nohash = "\.iso$";
          https-only = true;
        };
      };

      "/backups/" = {

        # share the contents of "/srv/copyparty"
        path = "/home/admin/luke_backups";
        # see `copyparty --help-accounts` for available options
        access = {
          # users get read-write
          rw = [
            "luke"
          ];
        };
        # see `copyparty --help-flags` for available options
        flags = {
          # "fk" enables filekeys (necessary for upget permission) (4 chars long)
          fk = 4;
          # scan for new files every 60sec
          scan = 60;
          # volflag "e2d" enables the uploads database
          e2d = true;
          # "d2t" disables multimedia parsers (in case the uploads are malicious)
          d2t = true;
          # skips hashing file contents if path matches *.iso
          nohash = "\.iso$";
          https-only = true;
        };
      };
    };
    # you may increase the open file limit for the process
    openFilesLimit = 8192;
  };

  services.xserver.enable = true;

  services.xserver.videoDrivers = [ "modesetting" ];

  age.secrets = {
    factorio-token = {
      file = ./secrets/factorio-token.age;
      owner = "factorio"; # adjust if using different user
      group = "factorio"; # adjust if using different group
    };
    factorio-server = {
      file = ./secrets/factorio-server.age;
      owner = "factorio";
      group = "factorio";
    };
    copyparty = {
      file = ./secrets/copyparty.age;
      path = "/run/keys/copyparty/luke_password";
      owner = "copyparty";
      group = "copyparty";
    };
    copyparty-aaron = {
      file = ./secrets/aaron-copyparty.age;
      path = "/run/keys/copyparty/aaron_password";
      owner = "copyparty";
      group = "copyparty";
    };
    copyparty-rye = {
      file = ./secrets/rye-copyparty.age;
      path = "/run/keys/copyparty/rye_password";
      owner = "copyparty";
      group = "copyparty";
    };
    copyparty-pg = {
      file = ./secrets/pg-copyparty.age;
      path = "/run/keys/copyparty/pg_password";
      owner = "copyparty";
      group = "copyparty";
    };
  };

  # Create the initial json file with placeholders
  environment.etc."factorio/extra_settings.json".text = builtins.toJSON {
    "game_password" = "@FACTORIO_PASSWORD@";
    "token" = "@FACTORIO_TOKEN@";
  };

  # Replace placeholders with actual secrets
  system.activationScripts.factorio-secrets = ''
    token=$(cat "${config.age.secrets.factorio-token.path}")
    server_password=$(cat "${config.age.secrets.factorio-server.path}")
    configFile=/etc/factorio/extra_settings.json

    # Use sed to replace both placeholders
    ${pkgs.gnused}/bin/sed -i \
      -e "s#@FACTORIO_TOKEN@#$token#" \
      -e "s#@FACTORIO_PASSWORD@#$server_password#" \
      "$configFile"

    # Ensure factorio user can read the file
    chown factorio:factorio "$configFile"
    chmod 600 "$configFile"
  '';

  services.factorio = {
    enable = true;
    public = true;

    username = "TheCarton";

    extraSettingsFile = "/etc/factorio/extra_settings.json";

    # Use headless version
    package = unstable.factorio-headless;

    # Use most recent save
    loadLatestSave = true;

    # Server settings
    saveName = "world"; # Name of your save file

    nonBlockingSaving = true;

    # Game settings
    game-name = "Carton of Doom"; # Server name shown in game browser

    # Description shown in server browser
    description = "Do you think God stays in heaven because he's afraid of what he's created?";

    # Network settings
    port = 34197; # Default Factorio port

    # Additional settings (optional)
    admins = [ "TheCarton" ]; # Server admins

    # Add any custom server settings here
    autosave-interval = 15; # Save every 15 minutes
  };

  # 1. enable vaapi on OS-level
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver # previously vaapiIntel
      vaapiVdpau
      intel-compute-runtime # OpenCL filter support (hardware tonemapping and subtitle burn-in)
      vpl-gpu-rt
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
      3921 # Copyparty
      3923 # Copyparty
      3945 # Copyparty
      3990 # Copyparty
    ];
    allowedTCPPortRanges = [
      {
        from = 12000; # Copyparty
        to = 12099;
      }
    ];

    allowedUDPPorts = [
      51413
      1900
      7359 # Discovery
      34197 # Factorio
      69 # Copyparty
      1900 # Copyparty
      3969 # Copyparty
      5353 # Copyparty
    ];
  };

  services.nginx = {
    enable = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts = {
      "static.cartonofdoom.win" = {
        forceSSL = true;
        enableACME = true;
        root = "/var/www/homepage";
        locations."/" = {
          index = "index.html";
        };
      };

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
      "files.cartonofdoom.win" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://unix:/dev/shm/party.sock";
        };
      };
    };
  };
  # This is needed for nginx to be able to read other processes
  # directories in `/run`. Else it will fail with (13: Permission denied)
  systemd.services.nginx.serviceConfig.ProtectHome = false;

  #-i unix:770:www:/dev/shm/party.sock listens on
  # /dev/shm/party.sock with permissions 0770;
  # only accessible to members of the www group.
  users.groups.www.members = [
    "nginx"
    "copyparty"
  ];

  # Most services will create sockets with 660 permissions.
  # This means you have to add nginx to their group.
  users.groups.copyparty.members = [ "nginx" ];

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
    xkb.layout = "us";
    xkb.variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.admin = {
    isNormalUser = true;
    description = "Admin";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "copyparty"
    ];
  };

  # for agenix to chown stuff properly.
  users.users.factorio = {
    group = "factorio";
    isSystemUser = true;
  };

  users.groups.factorio = { };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.variables.EDITOR = "hx";

  services.jellyfin = {
    enable = true;
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
