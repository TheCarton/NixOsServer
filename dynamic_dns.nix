# dynamic-dns.nix
#
# A small NixOS module for running one or more Cloudflare Dynamic DNS
# update scripts on a timer via systemd.

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.dynamicDns;

  mkDdnsService = name: domainCfg: {
    "ddns_${name}" = {
      description = "Cloudflare Dynamic DNS update for ${name}";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash ${domainCfg.script}";
        User = cfg.user;
      };
      path = [
        pkgs.curl
        pkgs.jq
      ];
    };
  };

  mkDdnsTimer = name: domainCfg: {
    "ddns_${name}" = {
      description = "Run ${name} DDNS update on a timer";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "1min";
        OnUnitActiveSec = domainCfg.interval or cfg.interval;
      };
    };
  };
in
{
  options.services.dynamicDns = {
    enable = mkEnableOption "Cloudflare Dynamic DNS update timers";

    user = mkOption {
      type = types.str;
      default = "root";
      description = "User to run the DDNS scripts as.";
    };

    interval = mkOption {
      type = types.str;
      default = "5min";
      description = "Default interval between DDNS updates (systemd time span, e.g. \"5min\", \"15min\").";
    };

    domains = mkOption {
      description = "Set of domains to keep updated, each pointing at its own update script.";
      default = { };
      type = types.attrsOf (
        types.submodule {
          options = {
            script = mkOption {
              type = types.str;
              description = ''
                Absolute path to the executable DDNS update script for this domain,
                as it exists on the target machine (e.g. "/etc/dynamic-dns/foo.sh").
                This is a plain string, not a Nix path, so flakes' pure evaluation
                won't try to read/copy it from outside the flake at build time.
              '';
            };
            interval = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Optional per-domain override of the update interval.";
            };
          };
        }
      );
    };
  };

  config = mkIf cfg.enable {
    systemd.services = mkMerge (mapAttrsToList mkDdnsService cfg.domains);
    systemd.timers = mkMerge (mapAttrsToList mkDdnsTimer cfg.domains);
  };
}
