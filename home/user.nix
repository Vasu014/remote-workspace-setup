{ config, pkgs, wsConfig, ... }:

{
  home.stateVersion = "24.11";

  # ===========================
  # ZSH
  # ===========================
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      # Navigation
      ll = "eza -la";
      ls = "eza";
      la = "eza -a";
      lt = "eza --tree";

      # Git
      g = "git";
      gs = "git status";
      gd = "git diff";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";
      lg = "lazygit";

      # Better defaults
      cat = "bat";
      find = "fd";
      grep = "rg";

      # Tmux
      ta = "tmux attach -t";
      tn = "tmux new -s";
      tl = "tmux list-sessions";
      tk = "tmux kill-session -t";

      # Claude Code sessions
      claude1 = "tmux new -s claude1 'claude'";
      claude2 = "tmux new -s claude2 'claude'";
      claude3 = "tmux new -s claude3 'claude'";

      # NixOS
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#dev-workspace";
      update = "sudo nix flake update /etc/nixos && rebuild";
      rollback = "sudo nixos-rebuild switch --rollback";
    };

    initExtra = ''
      # Starship prompt
      eval "$(starship init zsh)"

      # Zoxide (smart cd)
      eval "$(zoxide init zsh)"

      # FZF keybindings
      source ${pkgs.fzf}/share/fzf/key-bindings.zsh
      source ${pkgs.fzf}/share/fzf/completion.zsh

      # History
      HISTSIZE=50000
      SAVEHIST=50000
      setopt SHARE_HISTORY
      setopt HIST_IGNORE_DUPS
      setopt HIST_IGNORE_SPACE

      # Path
      export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$PATH"

      # Editor
      export EDITOR="vim"
    '';
  };

  # ===========================
  # STARSHIP PROMPT
  # ===========================
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;

      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[✗](bold red)";
      };

      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
      };

      git_branch.symbol = " ";
      nodejs.symbol = " ";
      python.symbol = " ";
      rust.symbol = " ";
      nix_shell.symbol = " ";
    };
  };

  # ===========================
  # TMUX
  # ===========================
  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
    historyLimit = 50000;
    escapeTime = 0;
    baseIndex = 1;
    keyMode = "vi";

    extraConfig = ''
      # Prefix: Ctrl+a
      unbind C-b
      set -g prefix C-a
      bind C-a send-prefix

      # Split panes
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # Navigate panes (vim keys)
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Resize panes
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # Mouse
      set -g mouse on

      # Status bar (Catppuccin-inspired)
      set -g status-position bottom
      set -g status-style 'bg=#1e1e2e fg=#cdd6f4'
      set -g status-left '#[fg=#89b4fa,bold] #S '
      set -g status-right '#[fg=#a6adc8] %H:%M '
      set -g status-left-length 30

      # Windows
      set -g window-status-format '#[fg=#6c7086] #I:#W '
      set -g window-status-current-format '#[fg=#89b4fa,bold] #I:#W '

      # Panes
      set -g pane-border-style 'fg=#313244'
      set -g pane-active-border-style 'fg=#89b4fa'

      # Reload
      bind r source-file ~/.config/tmux/tmux.conf \; display "Reloaded!"

      # Quick switch (Alt+number)
      bind -n M-1 select-window -t 1
      bind -n M-2 select-window -t 2
      bind -n M-3 select-window -t 3
      bind -n M-4 select-window -t 4
      bind -n M-5 select-window -t 5
    '';
  };

  # ===========================
  # OTHER TOOLS
  # ===========================
  programs.bat.enable = true;

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultOptions = [ "--height 40%" "--layout=reverse" "--border" ];
  };

  programs.git = {
    enable = true;
    userName = wsConfig.git.name;
    userEmail = wsConfig.git.email;
    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
      core.editor = "vim";
    };
    aliases = {
      co = "checkout";
      br = "branch";
      ci = "commit";
      st = "status";
      lg = "log --oneline --graph --decorate";
    };
  };
}
