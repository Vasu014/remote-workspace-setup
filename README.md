# Remote Dev Workspace

Reproducible NixOS configuration for remote development. Fork this repo and have a beautiful, fully-configured dev environment running in minutes.

## What's Included

- **Shell**: zsh + starship prompt + syntax highlighting + autosuggestions
- **Terminal**: tmux with vim keybindings + Catppuccin theme
- **Tools**: bat, fzf, ripgrep, fd, eza, lazygit, zoxide
- **Languages**: Node.js 22, Python 3.12 + uv, Rust
- **Network**: Tailscale for secure access
- **Security**: SSH key-only auth, firewall enabled

## Quick Start

### 1. Fork & Clone

Fork this repo on GitHub, then:

```bash
git clone https://github.com/YOUR_USERNAME/remote-workspace-setup.git
cd remote-workspace-setup
```

### 2. Customize Config

Edit `config.nix` with your details:

```nix
{
  username = "yourname";
  git = {
    name = "Your Name";
    email = "your.email@example.com";
  };
  timezone = "America/New_York";  # Your timezone
  hostname = "dev-workspace";
}
```

### 3. Provision Server

Create a cloud server (Hetzner, DigitalOcean, etc.):
- **Type**: 4+ vCPU, 8GB+ RAM recommended
- **Image**: Ubuntu 24.04
- **SSH Key**: Add your public key

### 4. Convert to NixOS

```bash
ssh root@<SERVER_IP>
curl https://raw.githubusercontent.com/elitak/nixos-infect/master/nixos-infect | NIX_CHANNEL=nixos-24.11 bash -x
# Wait for reboot, then reconnect
```

### 5. Deploy Config

```bash
ssh root@<SERVER_IP>
cd /etc
rm -rf nixos
git clone https://github.com/YOUR_USERNAME/remote-workspace-setup.git nixos
cd nixos
```

### 6. Configure Secrets

```bash
cp secrets.nix.example secrets.nix
vim secrets.nix  # Add your SSH public key
```

### 7. Generate Hardware Config

```bash
nixos-generate-config --show-hardware-config > hardware-configuration.nix
```

### 8. Build & Switch

```bash
nixos-rebuild switch --flake .#dev-workspace
```

### 9. Setup Tailscale (Optional)

```bash
tailscale up --ssh
```

Now you can SSH via Tailscale hostname instead of IP.

## Usage

### SSH Access

```bash
# Via Tailscale (recommended)
ssh yourname@dev-workspace

# Via IP
ssh -i ~/.ssh/your-key yourname@<SERVER_IP>
```

### Claude Code Sessions

```bash
claude1  # Start session 1
claude2  # Start session 2
claude3  # Start session 3

ta claude1  # Attach to session 1
tl          # List sessions
tk claude1  # Kill session 1
```

### Tmux Keys

| Key | Action |
|-----|--------|
| `Ctrl+a` | Prefix (instead of Ctrl+b) |
| `Prefix + \|` | Split vertical |
| `Prefix + -` | Split horizontal |
| `Prefix + h/j/k/l` | Navigate panes |
| `Prefix + 1-5` | Switch windows |
| `Alt + 1-5` | Quick switch windows |
| `Prefix + d` | Detach |

### System Management

```bash
rebuild   # Apply config changes
update    # Update flake + rebuild
rollback  # Revert to previous config
```

## Customization

### Add a Package

Edit `modules/packages.nix`:

```nix
environment.systemPackages = with pkgs; [
  # ... existing packages
  your-new-package
];
```

Then run `rebuild`.

### Add a Service

Edit `modules/services.nix`:

```nix
services.your-service = {
  enable = true;
  # ... config
};
```

### Change Shell Config

Edit `home/user.nix` for user-level changes (aliases, prompt, etc.)

## File Structure

```
.
├── flake.nix                 # Entry point, defines inputs
├── config.nix                # Your customizations (username, git, timezone)
├── hardware-configuration.nix # Machine-specific (not in git)
├── secrets.nix               # SSH keys (not in git)
├── secrets.nix.example       # Template for secrets
├── modules/
│   ├── system.nix            # Core NixOS settings
│   ├── services.nix          # SSH, Tailscale, etc.
│   ├── packages.nix          # System-wide packages
│   └── users.nix             # User accounts
└── home/
    └── user.nix              # Home-manager config (shell, tmux, etc.)
```

## Scaling Up

Need more RAM? Provision a bigger server and repeat steps 4-8. Your entire environment is defined in this repo — reproducible in minutes.

## License

MIT
