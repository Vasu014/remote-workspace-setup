{ config, pkgs, lib, wsConfig, ... }:

let
  # Load SSH keys from secrets file (not tracked in git)
  secrets = import ../secrets.nix;
in
{
  users.users.${wsConfig.username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = secrets.sshKeys;
  };

  users.users.root.openssh.authorizedKeys.keys = secrets.sshKeys;
}
