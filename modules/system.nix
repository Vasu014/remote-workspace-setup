{ config, pkgs, lib, wsConfig, ... }:

{
  system.stateVersion = "24.11";

  # Nix settings
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      # Allow rebuilding while offline if possible
      fallback = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # Boot
  boot.tmp.cleanOnBoot = true;

  # Networking
  networking = {
    hostName = wsConfig.hostname;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
      trustedInterfaces = [ "tailscale0" ];
      allowedUDPPorts = [ config.services.tailscale.port ];
    };
  };

  # Timezone & Locale
  time.timeZone = wsConfig.timezone;
  i18n.defaultLocale = "en_US.UTF-8";

  # Security
  security.sudo.wheelNeedsPassword = false;
}
