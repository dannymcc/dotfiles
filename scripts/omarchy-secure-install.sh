#!/bin/bash
#
# Omarchy Security Hardening Script
# ==================================
#
# Addresses security gaps in default Omarchy/Arch Linux installations.
#
# Inspired by security analysis at:
#   https://xn--gckvb8fzb.com/a-word-on-omarchy/
#
# Key issues this script addresses:
#   - Firewall not enabled by default despite pre-configured rules
#   - Increased attack surface from relaxed sudo/faillock settings
#   - SSH configuration gaps
#   - Missing commit signing for Git
#   - LLMNR enabled (name poisoning attack vector)
#
# Run after a fresh installation to harden the system.
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Default values
USE_TAILSCALE=false
SSH_KEY_PATH="$HOME/.ssh/id_ed25519.pub"
GITHUB_USERNAME=""
GIT_NAME=""
GIT_EMAIL=""
MAX_LOGIN_ATTEMPTS=3

# Parse command line arguments
show_help() {
    cat << EOF
Omarchy Security Hardening Script

Addresses security gaps identified in Omarchy's default configuration.
See: https://xn--gckvb8fzb.com/a-word-on-omarchy/

Usage: $(basename "$0") [OPTIONS]

Options:
    --tailscale             Enable Tailscale-only SSH access
    --ssh-key PATH          Path to SSH public key (default: ~/.ssh/id_ed25519.pub)
    --github-user USERNAME  GitHub username for credential helper
    --git-name "NAME"       Git user.name
    --git-email EMAIL       Git user.email
    --max-attempts N        Max failed login attempts before lockout (default: 3)
    --help                  Show this help message

Examples:
    $(basename "$0") --tailscale --github-user myuser --git-name "My Name" --git-email me@example.com
    $(basename "$0") --ssh-key ~/.ssh/id_rsa.pub --max-attempts 5

EOF
    exit 0
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --tailscale)
            USE_TAILSCALE=true
            shift
            ;;
        --ssh-key)
            SSH_KEY_PATH="$2"
            shift 2
            ;;
        --github-user)
            GITHUB_USERNAME="$2"
            shift 2
            ;;
        --git-name)
            GIT_NAME="$2"
            shift 2
            ;;
        --git-email)
            GIT_EMAIL="$2"
            shift 2
            ;;
        --max-attempts)
            MAX_LOGIN_ATTEMPTS="$2"
            shift 2
            ;;
        --help)
            show_help
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    print_error "Do not run this script as root. It will use sudo when needed."
    exit 1
fi

print_header "Omarchy Security Hardening"

echo "Configuration:"
echo "  Tailscale-only SSH: $USE_TAILSCALE"
echo "  SSH key: $SSH_KEY_PATH"
echo "  GitHub user: ${GITHUB_USERNAME:-not set}"
echo "  Git name: ${GIT_NAME:-not set}"
echo "  Git email: ${GIT_EMAIL:-not set}"
echo "  Max login attempts: $MAX_LOGIN_ATTEMPTS"
echo ""
read -p "Continue with these settings? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

# ============================================================================
# 1. Disable LLMNR (Link-Local Multicast Name Resolution)
# ============================================================================
#
# WHY: LLMNR is a name resolution protocol that can be exploited for
#      man-in-the-middle attacks. Attackers on the local network can respond
#      to LLMNR queries and redirect traffic to malicious hosts. This is a
#      common attack vector in penetration testing (e.g., Responder tool).
#      Modern networks should use proper DNS instead.
#
# ============================================================================
print_header "Disabling LLMNR"

if [[ -d /etc/systemd/resolved.conf.d ]]; then
    echo "Creating resolved.conf.d configuration..."
else
    sudo mkdir -p /etc/systemd/resolved.conf.d
fi

sudo tee /etc/systemd/resolved.conf.d/disable-llmnr.conf > /dev/null << 'EOF'
[Resolve]
LLMNR=no
EOF

sudo systemctl restart systemd-resolved
print_success "LLMNR disabled"

# ============================================================================
# 2. Configure UFW Firewall
# ============================================================================
#
# WHY: Omarchy ships with UFW rules pre-configured but the firewall service
#      is NOT actually enabled, leaving the system completely exposed.
#      This is a critical oversight - a firewall that doesn't run provides
#      zero protection. We enable UFW with sensible defaults: deny incoming,
#      allow outgoing, and optionally restrict SSH to Tailscale.
#
# ============================================================================
print_header "Configuring UFW Firewall"

if ! command -v ufw &> /dev/null; then
    print_warning "UFW not installed, installing..."
    sudo pacman -S --noconfirm ufw
fi

sudo ufw --force reset > /dev/null
sudo ufw default deny incoming
sudo ufw default allow outgoing

if [[ "$USE_TAILSCALE" == true ]]; then
    # Get Tailscale interface
    TAILSCALE_IFACE=$(ip -o link show | grep -o 'tailscale[0-9]*' | head -1)
    if [[ -n "$TAILSCALE_IFACE" ]]; then
        sudo ufw allow in on "$TAILSCALE_IFACE"
        print_success "Allowed all traffic on Tailscale interface ($TAILSCALE_IFACE)"
    else
        print_warning "Tailscale interface not found. Make sure Tailscale is running."
        sudo ufw allow in on tailscale0
    fi
else
    # Allow SSH from anywhere if not using Tailscale
    sudo ufw allow ssh
    print_success "Allowed SSH from all interfaces"
fi

sudo ufw --force enable
print_success "UFW enabled"

# ============================================================================
# 3. Configure SSH for Tailscale-only access (optional)
# ============================================================================
#
# WHY: SSH exposed to the public internet is a constant target for brute-force
#      attacks. By binding SSH only to your Tailscale IP, the service becomes
#      invisible to the public internet while remaining accessible through
#      your private Tailscale network. This is defense-in-depth: even if
#      someone discovers your SSH port, they cannot reach it without being
#      on your Tailscale network.
#
# ============================================================================
if [[ "$USE_TAILSCALE" == true ]]; then
    print_header "Configuring SSH for Tailscale-only access"

    TAILSCALE_IP=$(tailscale ip -4 2>/dev/null || echo "")

    if [[ -n "$TAILSCALE_IP" ]]; then
        sudo mkdir -p /etc/ssh/sshd_config.d
        sudo tee /etc/ssh/sshd_config.d/tailscale-only.conf > /dev/null << EOF
# Bind SSH only to Tailscale interface - invisible to public internet
ListenAddress $TAILSCALE_IP

# Disable password authentication - keys only
PasswordAuthentication no
EOF
        sudo systemctl restart sshd
        print_success "SSH now only listening on Tailscale IP: $TAILSCALE_IP"
    else
        print_error "Could not get Tailscale IP. Is Tailscale running?"
        print_warning "Skipping SSH Tailscale configuration"
    fi
fi

# ============================================================================
# 4. Configure login attempt limiting (PAM faillock)
# ============================================================================
#
# WHY: Omarchy increases the default faillock attempts from 3 to 10, making
#      brute-force attacks against local accounts easier. This is the opposite
#      of security hardening. We restore a sensible limit (default: 3) to lock
#      accounts after repeated failed attempts, preventing offline brute-force
#      attacks if someone gains physical access or a shell.
#
# ============================================================================
print_header "Configuring Login Attempt Limiting"

if [[ -f /etc/security/faillock.conf ]]; then
    sudo sed -i "s/^deny = .*/deny = $MAX_LOGIN_ATTEMPTS/" /etc/security/faillock.conf
    # Uncomment deny line if commented
    sudo sed -i "s/^# *deny = .*/deny = $MAX_LOGIN_ATTEMPTS/" /etc/security/faillock.conf
    print_success "Max login attempts set to $MAX_LOGIN_ATTEMPTS"
else
    print_warning "/etc/security/faillock.conf not found, skipping"
fi

# ============================================================================
# 5. Configure Git with SSH signing
# ============================================================================
#
# WHY: Git commits are trivially forgeable - anyone can set any name/email
#      in their git config. SSH commit signing cryptographically proves that
#      commits came from someone with access to your private key. GitHub
#      displays a "Verified" badge on signed commits. This prevents commit
#      impersonation and provides non-repudiation for your code contributions.
#
# ============================================================================
print_header "Configuring Git"

GIT_CONFIG_DIR="$HOME/.config/git"
mkdir -p "$GIT_CONFIG_DIR"

# Set user info if provided
if [[ -n "$GIT_NAME" ]]; then
    git config --global user.name "$GIT_NAME"
    print_success "Git user.name set to: $GIT_NAME"
fi

if [[ -n "$GIT_EMAIL" ]]; then
    git config --global user.email "$GIT_EMAIL"
    print_success "Git user.email set to: $GIT_EMAIL"
fi

# Configure SSH signing if key exists
if [[ -f "$SSH_KEY_PATH" ]]; then
    git config --global user.signingkey "$SSH_KEY_PATH"
    git config --global gpg.format ssh
    git config --global commit.gpgsign true
    git config --global tag.gpgsign true
    print_success "Git SSH signing enabled with: $SSH_KEY_PATH"
else
    print_warning "SSH key not found at $SSH_KEY_PATH, skipping signing config"
fi

# Recommended git workflow settings
git config --global init.defaultBranch master
git config --global pull.rebase true              # Cleaner history than merge commits
git config --global push.autoSetupRemote true     # Auto-set upstream on first push
git config --global diff.algorithm histogram      # Better diffs for moved code
git config --global diff.colorMoved plain         # Highlight moved blocks
git config --global diff.mnemonicPrefix true      # Clearer a/b prefixes in diffs
git config --global commit.verbose true           # Show diff in commit message editor
git config --global column.ui auto                # Columnar output where sensible
git config --global branch.sort -committerdate    # Recent branches first
git config --global tag.sort -version:refname     # Semantic version sorting
git config --global rerere.enabled true           # Remember conflict resolutions
git config --global rerere.autoupdate true        # Auto-apply remembered resolutions
print_success "Git workflow optimizations applied"

# GitHub credential helper - uses gh CLI for seamless auth
if [[ -n "$GITHUB_USERNAME" ]] && command -v gh &> /dev/null; then
    git config --global credential.https://github.com.helper ""
    git config --global credential.https://github.com.helper "!/usr/bin/gh auth git-credential"
    git config --global credential.https://gist.github.com.helper ""
    git config --global credential.https://gist.github.com.helper "!/usr/bin/gh auth git-credential"
    print_success "GitHub credential helper configured"
fi

# ============================================================================
# 6. Disable GNOME screensaver (for Hyprland setups using hyprlock)
# ============================================================================
#
# WHY: If both GNOME screensaver and hyprlock are configured with similar
#      timeouts, they may race or interfere with each other. Since Omarchy
#      uses Hyprland with hypridle/hyprlock for idle locking, we disable the
#      GNOME screensaver to prevent conflicts and ensure hyprlock handles
#      all screen locking consistently.
#
# ============================================================================
print_header "Configuring Screensaver"

if command -v gsettings &> /dev/null; then
    if gsettings get org.gnome.desktop.screensaver idle-activation-enabled &> /dev/null; then
        gsettings set org.gnome.desktop.screensaver idle-activation-enabled false
        print_success "GNOME screensaver disabled (hyprlock will handle locking)"
    fi
fi

# ============================================================================
# Summary
# ============================================================================
print_header "Security Hardening Complete"

echo "Applied changes:"
echo "  ✓ LLMNR disabled (prevents name poisoning attacks)"
echo "  ✓ UFW firewall enabled (was pre-configured but not running)"
if [[ "$USE_TAILSCALE" == true ]]; then
    echo "  ✓ SSH restricted to Tailscale (invisible to public internet)"
fi
echo "  ✓ Login attempts limited to $MAX_LOGIN_ATTEMPTS (was increased to 10)"
if [[ -f "$SSH_KEY_PATH" ]]; then
    echo "  ✓ Git SSH signing enabled (verified commits)"
fi
echo ""
echo -e "${YELLOW}Recommended next steps:${NC}"
echo "  • Add your SSH key to GitHub as a signing key"
echo "  • Test SSH access before logging out"
echo "  • Consider installing OpenSnitch for application-level firewall"
if [[ "$USE_TAILSCALE" == true ]]; then
    echo "  • Ensure Tailscale is set to start on boot: sudo systemctl enable tailscaled"
fi
echo ""
echo "For more context on these security improvements, see:"
echo "  https://xn--gckvb8fzb.com/a-word-on-omarchy/"
