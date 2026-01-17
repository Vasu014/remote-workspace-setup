# Remote Dev Workspace

Reproducible NixOS configuration for remote development. Fork this repo and have a fully-configured dev environment running in minutes.

## Why Remote Dev?

**Run AI coding agents 24/7, accessible from anywhere.**

This setup uses **tmux** to maintain persistent terminal sessions on a cloud server. Your AI agents keep running even when you disconnect:

- **Multiple agents in parallel** — Run Claude Code, Aider, OpenCode, or any CLI-based AI tool in separate tmux sessions, all working on different tasks simultaneously
- **Access from anywhere** — SSH in from your laptop, phone ([Termius](https://termius.com/)), tablet, or any device. Your sessions are always there, exactly where you left them
- **Never lose work** — Connection dropped? Laptop died? No problem. Reconnect and your agents are still running, mid-task
- **Persistent context** — Long-running agents maintain their conversation history and working state across days or weeks
- **Low latency for agents** — Your AI tools run on a server with fast, stable internet — no more local network issues slowing down API calls

```
┌─────────────────────────────────────────────────────────┐
│  Your Cloud Server (always running)                     │
│                                                         │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐       │
│  │   claude1   │ │   claude2   │ │   claude3   │       │
│  │  (refactor) │ │   (tests)   │ │   (docs)    │       │
│  └─────────────┘ └─────────────┘ └─────────────┘       │
│                                                         │
└─────────────────────────────────────────────────────────┘
         ▲                ▲                ▲
         │                │                │
    ┌────┴────┐     ┌────┴────┐     ┌────┴────┐
    │ Laptop  │     │ Phone   │     │ Tablet  │
    └─────────┘     └─────────┘     └─────────┘
```

> **Note**: For the best experience, use a terminal with a [Nerd Font](https://www.nerdfonts.com/) installed (e.g., JetBrainsMono Nerd Font, FiraCode Nerd Font). This enables the icons in the starship prompt.

---

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
- [ ] **Hetzner Cloud account** — [hetzner.com/cloud](https://www.hetzner.com/cloud)
- [ ] **Nerd Font** (optional) — for prompt icons: [nerdfonts.com](https://www.nerdfonts.com/)

> This setup has been tested on Hetzner Cloud. It should work on other providers (DigitalOcean, Vultr, etc.) but your mileage may vary.

---

## Quick Start

### Phase 1: Local Setup (on your laptop)

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

#### 4. Create Hetzner Server

In Hetzner Cloud console:

| Setting | Value |
|---------|-------|
| **Image** | Ubuntu 24.04 |
| **Type** | CX22 or larger (2+ vCPU, 4GB+ RAM) |
| **Location** | Closest to you |
| **SSH Key** | Add your public key |

To get your public key (run on your laptop):
```bash
cat ~/.ssh/id_ed25519.pub
```

#### 5. Convert to NixOS

SSH into your new server:

```bash
ssh root@YOUR_SERVER_IP
```

Run nixos-infect to convert Ubuntu to NixOS:

```bash
curl -L https://raw.githubusercontent.com/elitak/nixos-infect/master/nixos-infect | NIX_CHANNEL=nixos-24.11 bash -x
```

> **What this does**: Converts Ubuntu to NixOS in-place. The server will reboot automatically.
>
> **Wait time**: ~5-10 minutes. You'll be disconnected. Wait, then reconnect.

#### 6. Reconnect & Clone Your Config

```bash
ssh root@YOUR_SERVER_IP
```

```bash
cd /etc
rm -rf nixos
git clone https://github.com/YOUR_USERNAME/remote-workspace-setup.git nixos
cd nixos
```

#### 7. Configure SSH Keys

Your SSH key is already on the server (that's how you logged in). Copy it to secrets.nix:

```bash
# Create secrets.nix from template
cp secrets.nix.example secrets.nix

# Open secrets.nix in editor
nano secrets.nix
```

Now paste your SSH key. To see what key to paste, run:

```bash
cat ~/.ssh/authorized_keys
```

Copy that entire line and paste it into `secrets.nix`:

```nix
{
  sshKeys = [
    "ssh-ed25519 AAAA...your-full-key-here..."
  ];
}
```

Save and exit (in nano: `Ctrl+O`, `Enter`, `Ctrl+X`).

#### 8. Generate Hardware Config

```bash
nixos-generate-config --show-hardware-config > hardware-configuration.nix
```

#### 9. Build & Switch

```bash
nixos-rebuild switch --flake .#dev-workspace
```

> **Build time**: ~5-15 minutes on first run.

#### 10. Login as Your User

```bash
exit
ssh YOUR_USERNAME@YOUR_SERVER_IP
```

You'll see a welcome message with final setup steps.

---

### Phase 3: Final Setup (on the server, as your user)

On first login, you'll see setup instructions. Run these:

```bash
# 1. Authenticate GitHub CLI
gh auth login

# 2. Install Claude Code
npm install -g @anthropic-ai/claude-code

# 3. (Optional) Enable Tailscale for easier SSH
sudo tailscale up --ssh

# 4. Mark setup complete (hides the welcome message)
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
- **Check Hetzner console** — use the web console to see boot progress
- **Verify IP** — IP should stay the same, but double-check in Hetzner dashboard

### Can't SSH after nixos-rebuild

You may have misconfigured `secrets.nix`. Use Hetzner's **web console** to access the server and fix it:

```bash
cat /etc/nixos/secrets.nix    # Check the file
nano /etc/nixos/secrets.nix   # Fix if needed
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

Log out and back in (group membership needs refresh):

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
