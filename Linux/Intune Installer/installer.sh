#!/usr/bin/env bash
#
# Microsoft Intune Portal Installer
#
# Installs Microsoft Intune Portal and its dependencies (including Microsoft Edge)
# on supported Linux distributions.
#
# Supported distributions:
#   - Ubuntu 22.04, 24.04, 26.04
#   - RHEL/AlmaLinux 8, 9, 10
#
# Usage:
#   ./installer.sh [OPTIONS]
#
# Options:
#   --insiders-fast        Use the insiders-fast channel instead of prod
#   --local-package <path> Install from a local .deb/.rpm file instead of the repo
#   --verbose              Show detailed output to the terminal (in addition to the log)
#   -h, --help             Show this help message
#

set -eu${DEBUG:+x}o pipefail

# Handle --help before elevating to root
for arg in "$@"; do
    if [[ "$arg" == "-h" || "$arg" == "--help" ]]; then
        sed -n '/^# Usage:/,/^[^#]/p' "$0" | head -n -1 | sed 's/^# \?//'
        exit 0
    fi
done

# Elevate to root if not already running as root (before arg parsing so $@ is intact)
if [[ $EUID -ne 0 ]]; then
    exec sudo bash "$0" "$@"
fi

# --- Defaults ---
CHANNEL="prod"
LOCAL_PACKAGE=""
VERBOSE=false
# Use the invoking user's home directory, not root's
USER_HOME="${SUDO_USER:+$(eval echo ~"$SUDO_USER")}"
LOG_FILE="${USER_HOME:-$HOME}/intune-installer.log"

# --- Functions ---

usage() {
    sed -n '/^# Usage:/,/^[^#]/p' "$0" | head -n -1 | sed 's/^# \?//'
    exit 0
}

log() {
    echo "$1" >&7
}

die() {
    # Write to original stdout (fd 7) if available, otherwise stderr
    if { true >&7; } 2>/dev/null; then
        echo "Error: $1" >&7
    fi
    echo "Error: $1" >&2
    exit 1
}

detect_arch() {
    local arch
    arch=$(dpkg --print-architecture 2>/dev/null || rpm --eval '%{_arch}' 2>/dev/null || uname -m)
    case "$arch" in
        x86_64)  echo "amd64" ;;
        aarch64) echo "arm64" ;;
        *)       echo "$arch" ;;
    esac
}

# Remove duplicate Edge repo files that Edge's postinst script may create.
# We maintain a single microsoft-edge.list — any others are duplicates.
cleanup_edge_repo_duplicates() {
    local sources_dir="/etc/apt/sources.list.d"
    for f in "$sources_dir"/microsoft-edge-*.list; do
        [ -f "$f" ] || continue
        sudo rm -f "$f"
    done
}

# --- Argument Parsing ---

while [[ $# -gt 0 ]]; do
    case "$1" in
        --insiders-fast)
            CHANNEL="insiders-fast"
            shift
            ;;
        --local-package)
            [[ $# -ge 2 ]] || die "--local-package requires a file path argument"
            LOCAL_PACKAGE="$2"
            shift 2
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            die "Unknown option: $1 (see --help)"
            ;;
    esac
done

if [[ -n "$LOCAL_PACKAGE" && ! -f "$LOCAL_PACKAGE" ]]; then
    die "Local package not found: $LOCAL_PACKAGE"
fi

# --- Pre-flight ---

# Read distro information
. /etc/os-release
DISTRO="$ID"
RELEASE="$VERSION_ID"
ARCH=$(detect_arch)

# Print summary
echo "============================================="
echo " Microsoft Intune Portal Installer"
echo "============================================="
echo " Distro:       $DISTRO $RELEASE"
echo " Architecture: $ARCH"
echo " Channel:      $CHANNEL"
if [[ -n "$LOCAL_PACKAGE" ]]; then
    echo " Local package: $LOCAL_PACKAGE"
fi
echo " Log file:     $LOG_FILE"
echo "============================================="
echo ""

# Redirect output to log file, keeping fd 7 for user-facing messages
exec 7>&1
if $VERBOSE; then
    exec &> >(tee -a "$LOG_FILE")
else
    exec &>"$LOG_FILE"
fi

# --- Distro-specific installation ---

case "$DISTRO" in
"ubuntu")
    # Validate supported release
    if [[ "$RELEASE" != "22.04" && "$RELEASE" != "24.04" && "$RELEASE" != "26.04" ]]; then
        die "Ubuntu $RELEASE is not supported. Supported versions: 22.04, 24.04, 26.04"
    fi

    CODENAME="$VERSION_CODENAME"

    log "Installing prerequisites..."

    sudo apt-get -y install curl gpg

    # Import Microsoft GPG key (idempotent)
    if [[ ! -f /usr/share/keyrings/microsoft.gpg ]]; then
        curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > "$HOME/microsoft.gpg"
        sudo install -o root -g root -m 644 "$HOME/microsoft.gpg" /usr/share/keyrings/
        rm -f "$HOME/microsoft.gpg"
    fi

    # Clean up any pre-existing Edge repo files to avoid duplicates
    cleanup_edge_repo_duplicates

    # Configure repo for portal and dependencies
    # For insiders-fast, the URL path stays as "prod" and "insiders-fast" is the apt component
    if [[ "$CHANNEL" == "insiders-fast" ]]; then
        APT_COMPONENT="insiders-fast"
    else
        APT_COMPONENT="$CODENAME"
    fi
    echo "deb [arch=$ARCH signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/ubuntu/$RELEASE/prod $APT_COMPONENT main" \
        | sudo tee /etc/apt/sources.list.d/microsoft-$CHANNEL.list > /dev/null

    # Configure repo for Edge
    echo "deb [arch=$ARCH signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/edge stable main" \
        | sudo tee /etc/apt/sources.list.d/microsoft-edge.list > /dev/null

    log "Updating package information..."
    sudo apt-get update

    # Install Edge if not already present
    if ! command -v microsoft-edge &>/dev/null; then
        log "Installing Microsoft Edge..."
        sudo apt-get -y install microsoft-edge-stable

        # Edge's postinst may add duplicate repo files — clean them up
        cleanup_edge_repo_duplicates
    else
        log "Microsoft Edge is already installed."
    fi

    # Install Intune Portal
    log "Installing Intune Portal..."
    if [[ -n "$LOCAL_PACKAGE" ]]; then
        log "Using local package: $LOCAL_PACKAGE"
        sudo apt-get -y --allow-downgrades install "$(readlink -f "$LOCAL_PACKAGE")"
    else
        sudo apt-get -y install intune-portal
    fi
    ;;

"rhel"|"almalinux")
    MAJOR="${RELEASE%%.*}"

    # Validate supported release
    if [[ "$MAJOR" != "8" && "$MAJOR" != "9" && "$MAJOR" != "10" ]]; then
        die "$DISTRO $RELEASE is not supported. Supported major versions: 8, 9, 10"
    fi

    log "Installing prerequisites..."

    # RHEL 10+ uses a newer Microsoft GPG signing key
    if [[ "$MAJOR" -ge 10 ]]; then
        MS_GPG_KEY="https://packages.microsoft.com/rhel/$MAJOR/$CHANNEL/repodata/repomd.xml.key"
        # RHEL 10 requires EPEL for webkitgtk6.0 dependency
        rpm -q epel-release || sudo dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm
    else
        MS_GPG_KEY="https://packages.microsoft.com/keys/microsoft.asc"
    fi

    # For portal and dependencies
    sudo dnf config-manager --add-repo https://packages.microsoft.com/rhel/$MAJOR/prod

    # Import Microsoft GPG key
    sudo rpm --import "$MS_GPG_KEY"

    # Configure repo for portal and dependencies
    sudo tee /etc/yum.repos.d/microsoft-${CHANNEL}.repo > /dev/null <<EOF
[microsoft-${CHANNEL}]
name=Microsoft $CHANNEL - RHEL $MAJOR
baseurl=https://packages.microsoft.com/rhel/$MAJOR/$CHANNEL
enabled=1
gpgcheck=1
gpgkey=$MS_GPG_KEY
EOF

    # Configure repo for Edge
    sudo tee /etc/yum.repos.d/microsoft-edge.repo > /dev/null <<EOF
[microsoft-edge]
name=Microsoft Edge
baseurl=https://packages.microsoft.com/yumrepos/edge
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

    log "Updating package information..."

    # Install Edge if not already present
    if ! command -v microsoft-edge &>/dev/null; then
        log "Installing Microsoft Edge..."
        sudo dnf -y install microsoft-edge-stable
    else
        log "Microsoft Edge is already installed."
    fi

    # Install Intune Portal
    log "Installing Intune Portal..."
    if [[ -n "$LOCAL_PACKAGE" ]]; then
        log "Using local package: $LOCAL_PACKAGE"
        sudo dnf -y install "$(readlink -f "$LOCAL_PACKAGE")"
    else
        sudo dnf -y install intune-portal
    fi
    ;;

*)
    die "$DISTRO is not a supported distribution. Supported: Ubuntu 22.04/24.04/26.04, RHEL/AlmaLinux 8/9/10"
    ;;
esac

# --- Done ---
log ""
log "Installation complete. Log file: $LOG_FILE"
