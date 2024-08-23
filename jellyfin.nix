{ config, pkgs, ... }:
# from melvyn2
# https://discourse.nixos.org/t/trouble-getting-quicksync-to-work-with-jellyfin/42275
let
  nixos-unstable = builtins.getFlake "nixpkgs/nixos-unstable";
  jellyfin-ffmpeg-overlay = (
    final: prev: {
      jellyfin-ffmpeg = prev.jellyfin-ffmpeg.override {
        ffmpeg_6-full = prev.ffmpeg_6-full.override {
          withMfx = false;
          withVpl = true;
        };
      };
    }
  );
  unstable = (
    import nixos-unstable {
      config.allowUnfree = true;
      overlays = [ jellyfin-ffmpeg-overlay ];
    }
  );
in
{
  services.jellyfin = {
    enable = true;
    package = unstable.jellyfin;
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  environment.variables = {
    NEOReadDebugKeys = "1";
    OverrideGpuAddressSpace = "48";
  };

  systemd.services."jellyfin".environment = {
    NEOReadDebugKeys = "1";
    OverrideGpuAddressSpace = "48";
  };

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-compute-runtime
      unstable.onevpl-intel-gpu
    ];
  };
}
