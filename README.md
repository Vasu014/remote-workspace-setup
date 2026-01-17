# Remote Dev Workspace

Reproducible NixOS configuration for remote development. Fork this repo and have a fully-configured dev environment running in minutes.

![Terminal Preview](https://via.placeholder.com/800x400?text=Your+Beautiful+Terminal+Here)

> **Note**: For the best experience, use a terminal with a [Nerd Font](https://www.nerdfonts.com/) installed (e.g., JetBrainsMono Nerd Font, FiraCode Nerd Font). This enables the icons in the starship prompt.

## What's Included

| Category | Tools |
|----------|-------|
| **Shell** | zsh, starship prompt, syntax highlighting, autosuggestions |
| **Terminal** | tmux with vim keybindings, Catppuccin theme |
| **Editors** | neovim, vim |
| **CLI Tools** | bat, fzf, ripgrep, fd, eza, lazygit, zoxide, jq, yq |
| **Languages** | Node.js 22, Python 3.12 + uv |
| **Containers** | Docker with auto-prune |
| **Network** | Tailscale for secure access |
| **Security** | SSH key-only auth, firewall enabled |

---

## Prerequisites

Before you begin, make sure you have:

- [ ] **GitHub account** — to fork this repo
- [ ] **SSH key pair** — check with `ls ~/.ssh/id_*.pub`
  - If none exists: `ssh-keygen -t ed25519`
- [ ] **Cloud provider account** — Hetzner, DigitalOcean, Vultr, or similar
- [ ] **Nerd Font** (optional) — for prompt icons: [nerdfonts.com](https://www.nerdfonts.com/)

---

## Quick Start

### Phase 1: Local Setup

#### 1. Fork & Clone

Fork this repo on GitHub, then:

```bash
git clone https://github.com/YOUR_USERNAME/remote-workspace-setup.git
cd remote-workspace-setup
```

#### 2. Customize Config

Edit `config.nix` with your details:

```nix
{
  username = "yourname";      # Linux username
  git = {
    name = "Your Name";       # For git commits
    email = "you@example.com";
  };
  timezone = "America/New_York";  # Your timezone
  hostname = "dev-workspace";
}
```

> Find your timezone: [List of tz database time zones](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)

#### 3. Push Your Changes

```bash
git add -A
git commit -m "Configure for my setup"
git push
```

---

### Phase 2: Server Setup

#### 4. Create Cloud Server

Create a server with your cloud provider:

| Setting | Value |
|---------|-------|
| **Image** | Ubuntu 24.04 |
| **Size** | 4+ vCPU, 8GB+ RAM recommended |
| **Region** | Closest to you |
| **SSH Key** | Paste your public key (`cat ~/.ssh/id_ed25519.pub`) |

**Tested providers**: Hetzner Cloud, DigitalOcean, Vultr, Linode

#### 5. Convert to NixOS

SSH into your server and run nixos-infect:

```bash
ssh root@YOUR_SERVER_IP
```

```bash
curl -L https://raw.githubusercontent.com/elitak/nixos-infect/master/nixos-infect | NIX_CHANNEL=nixos-24.11 bash -x
```

> **What this does**: Converts Ubuntu to NixOS in-place. The server will reboot automatically.
>
> **Wait time**: ~5-10 minutes. You'll be disconnected. Wait, then reconnect.

#### 6. Reconnect & Deploy

```bash
ssh root@YOUR_SERVER_IP
```

```bash
# Remove default NixOS config
cd /etc
rm -rf nixos

# Clone your forked repo
git clone https://github.com/YOUR_USERNAME/remote-workspace-setup.git nixos
cd nixos
```

#### 7. Configure SSH Keys

```bash
# Copy the template
cp secrets.nix.example secrets.nix

# Add your SSH public key (paste the output of the next command)
echo "Your public key:"
cat ~/.ssh/authorized_keys
```

Edit `secrets.nix` and paste your key:

```bash
nano secrets.nix   # or: vim secrets.nix
```

```nix
{
  sshKeys = [
    "ssh-ed25519 AAAA... your-key-here"
  ];
}
```

#### 8. Generate Hardware Config

```bash
nixos-generate-config --show-hardware-config > hardware-configuration.nix
```

#### 9. Build & Switch

For **x86** servers (most common):
```bash
nixos-rebuild switch --flake .#dev-workspace
```

For **ARM** servers (Oracle Cloud, AWS Graviton):
```bash
nixos-rebuild switch --flake .#dev-workspace-arm
```

> **Build time**: ~5-15 minutes on first run.

#### 10. Login as Your User

```bash
# Exit root session
exit

# SSH as your new user
ssh YOUR_USERNAME@YOUR_SERVER_IP
```

You'll see a welcome message with final setup steps.

---

### Phase 3: Final Setup

On first login, you'll see setup instructions. Run these:

```bash
# 1. Authenticate GitHub CLI
gh auth login

# 2. Install Claude Code
npm install -g @anthropic-ai/claude-code

# 3. (Optional) Enable Tailscale SSH
sudo tailscale up --ssh

# 4. Mark setup complete
touch ~/.setup-complete
```

---

## Usage

### SSH Access

```bash
# Via IP
ssh yourname@YOUR_SERVER_IP

# Via Tailscale (after tailscale up --ssh)
ssh yourname@dev-workspace
```

### Claude Code Sessions

```bash
claude1  # Start session 1 in tmux
claude2  # Start session 2
claude3  # Start session 3

ta claude1  # Attach to session
tl          # List sessions
tk claude1  # Kill session
```

### Tmux Keybindings

| Key | Action |
|-----|--------|
| `Ctrl+a` | Prefix (instead of Ctrl+b) |
| `Prefix + \|` | Split vertical |
| `Prefix + -` | Split horizontal |
| `Prefix + h/j/k/l` | Navigate panes |
| `Prefix + H/J/K/L` | Resize panes |
| `Alt + 1-5` | Quick switch windows |
| `Prefix + d` | Detach |

### System Management

```bash
rebuild   # Apply config changes
update    # Update flake + rebuild
rollback  # Revert to previous config
```

---

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
};
```

### Change Shell Config

Edit `home/user.nix` for aliases, prompt settings, etc.

---

## File Structure

```
.
├── flake.nix                 # Entry point
├── config.nix                # ⬅ YOUR CUSTOMIZATIONS
├── secrets.nix               # SSH keys (git-ignored)
├── secrets.nix.example       # Template for secrets
├── hardware-configuration.nix # Auto-generated (git-ignored)
├── modules/
│   ├── system.nix            # Core NixOS settings
│   ├── services.nix          # SSH, Tailscale, Docker
│   ├── packages.nix          # System packages
│   └── users.nix             # User accounts
└── home/
    └── user.nix              # Shell, tmux, git config
```

---

## Troubleshooting

### Can't SSH after nixos-infect

- **Wait longer** — reboot can take 5-10 minutes
- **Check cloud console** — use provider's web console to see boot progress
- **Verify IP** — some providers change IP after reboot

### Can't SSH after nixos-rebuild

You may have misconfigured `secrets.nix`. Use your cloud provider's **web console** to:

```bash
# Check the secrets file
cat /etc/nixos/secrets.nix

# Make sure your key is there and correctly formatted
# Then rebuild
nixos-rebuild switch --flake /etc/nixos#dev-workspace
```

### Build fails with "file not found"

Make sure you generated the hardware config:

```bash
nixos-generate-config --show-hardware-config > /etc/nixos/hardware-configuration.nix
```

### Starship icons not showing

Install a [Nerd Font](https://www.nerdfonts.com/) on your **local machine** and configure your terminal to use it.

### Docker permission denied

Log out and back in after first rebuild (group membership needs refresh):

```bash
exit
ssh yourname@YOUR_SERVER_IP
docker ps  # Should work now
```

---

## Scaling Up

Need more power? Provision a bigger server and repeat Phase 2. Your entire environment is defined in code — reproducible in minutes.

---

## License

MIT
