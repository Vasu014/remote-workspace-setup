{ config, pkgs, lib, ... }:

{
  # Enable zsh system-wide
  programs.zsh.enable = true;

  # System packages
  environment.systemPackages = with pkgs; [
    # === Core Utilities ===
    vim
    neovim
    wget
    curl
    htop
    btop
    unzip

    # === Git & VCS ===
    git
    gh           # GitHub CLI
    lazygit      # Git TUI

    # === File Navigation & Search ===
    bat          # Better cat
    fzf          # Fuzzy finder
    ripgrep      # Better grep
    fd           # Better find
    eza          # Better ls
    tree
    jq           # JSON processor
    yq           # YAML processor

    # === Terminal ===
    tmux
    starship     # Prompt
    zoxide       # Smart cd

    # === Node.js ===
    nodejs_22
    nodePackages.npm
    nodePackages.pnpm

    # === Python ===
    python312
    python312Packages.pip
    uv           # Fast package manager

    # === Build Tools ===
    gcc
    gnumake
    pkg-config
    openssl

    # === Networking ===
    tailscale
  ];

  # Docker
  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };
}
