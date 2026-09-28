#!/bin/zsh

# Intune macOS container tooling detection script
# Purpose: Detect local workload container capability on macOS.
# This intentionally excludes normal macOS app sandbox containers such as:
# ~/Library/Containers and /usr/libexec/containermanagerd

FOUND=0
PKG_FOUND=0
CLI_FOUND=0
DESKTOP_APP_FOUND=0
PROCESS_FOUND=0
CONFIG_FOUND=0
CONTAINER_INSTANCE_FOUND=0
CONTAINER_RUNTIME_CHECKED=0

log() {
  echo "$1"
}

finish_detection() {
  log ""
  log "=== Detection Result ==="

  if [ "$FOUND" -eq 1 ]; then
    log "Result: Container tooling or workload-container evidence detected."
    log ""
    log "Summary:"
    [ "$PKG_FOUND" -eq 1 ] && log "- Installer/package receipt evidence was found."
    [ "$CLI_FOUND" -eq 1 ] && log "- Container command-line tooling was found."
    [ "$DESKTOP_APP_FOUND" -eq 1 ] && log "- A container desktop app was found."
    [ "$PROCESS_FOUND" -eq 1 ] && log "- A container runtime-related process is currently running."
    [ "$CONFIG_FOUND" -eq 1 ] && log "- Container runtime/configuration folders were found."
    [ "$CONTAINER_INSTANCE_FOUND" -eq 1 ] && log "- One or more container instances were found."
    log ""
    log "Interpretation: this device has local workload container capability or evidence. Review the sections above to distinguish installed tooling from currently running containers."
    exit 0
  fi

  log "Result: No local workload container tooling detected."
  log ""
  log "Interpretation: the script did not find common container package receipts, CLIs, desktop apps, active runtime processes, runtime/config folders, or container instances."
  exit 1
}

log "=== Intune macOS Container Detection ==="
log "Device: $(scutil --get ComputerName 2>/dev/null)"
log "Date: $(date)"
log ""

log "Checking package receipts..."
PKG_MATCHES=$(pkgutil --pkgs 2>/dev/null | grep -Eim 20 'docker|podman|rancher|orbstack|colima|lima|containerd|nerdctl|apple.*container|com\.apple\.container')

if [ -n "$PKG_MATCHES" ]; then
  log "Container-related package receipt found:"
  echo "$PKG_MATCHES"
  PKG_FOUND=1
  FOUND=1
else
  log "No container-related package receipts found."
  log "What this means: no matching macOS installer receipts were found for common workload container tools such as Apple Container, Docker, Podman, Rancher Desktop, OrbStack, Colima, Lima, containerd, or nerdctl."
fi

log ""
log "Checking CLI tools..."
for bin in container docker podman nerdctl ctr colima limactl lima; do
  BIN_PATH=$(command -v "$bin" 2>/dev/null)
  if [ -n "$BIN_PATH" ]; then
    log "Found CLI: $bin at $BIN_PATH"
    VERSION_OUTPUT=$("$BIN_PATH" --version 2>/dev/null | head -n 1)
    if [ -n "$VERSION_OUTPUT" ]; then
      log "Version: $VERSION_OUTPUT"
    fi
    CLI_FOUND=1
    FOUND=1
  fi
done
if [ "$CLI_FOUND" -eq 0 ]; then
  log "No supported container CLI tools were found on PATH."
  log "What this means: commands such as container, docker, podman, nerdctl, ctr, colima, limactl, or lima were not available to this script."
fi

log ""
log "Checking common container desktop apps..."
for app in \
  "/Applications/Docker.app" \
  "/Applications/Podman Desktop.app" \
  "/Applications/Rancher Desktop.app" \
  "/Applications/OrbStack.app"; do
  if [ -d "$app" ]; then
    log "Found app: $app"
    DESKTOP_APP_FOUND=1
    FOUND=1
  fi
done
if [ "$DESKTOP_APP_FOUND" -eq 0 ]; then
  log "No common container desktop apps found."
  log "What this means: Docker Desktop, Podman Desktop, Rancher Desktop, and OrbStack were not found in /Applications. This does not rule out CLI-only tooling such as Apple Container."
fi

log ""
log "Checking active container-related processes..."
PROCESS_MATCHES=$(ps aux 2>/dev/null | grep -Ei 'docker|podman|containerd|colima|limactl|lima|nerdctl|orbstack|rancher' | grep -v grep)

if [ -n "$PROCESS_MATCHES" ]; then
  log "Active container-related process found:"
  echo "$PROCESS_MATCHES"
  PROCESS_FOUND=1
  FOUND=1
else
  log "No active workload-container runtime processes found."
  log "What this means: no obvious Docker, Podman, containerd, Colima, Lima, nerdctl, OrbStack, or Rancher runtime process is currently running. Installed tooling can still be present even when no runtime process is active."
fi

log ""
log "Checking common runtime/config folders for local users..."
for user_home in /Users/*; do
  [ -d "$user_home" ] || continue
  case "$user_home" in
    /Users/Shared) continue ;;
  esac

  for path in \
    "$user_home/.docker" \
    "$user_home/.config/containers" \
    "$user_home/.colima" \
    "$user_home/.lima" \
    "$user_home/Library/Application Support/com.docker.docker" \
    "$user_home/Library/Application Support/io.podman_desktop.PodmanDesktop" \
    "$user_home/Library/Application Support/rancher-desktop" \
    "$user_home/Library/Application Support/OrbStack"; do
    if [ -e "$path" ]; then
      log "Found runtime/config path: $path"
      CONFIG_FOUND=1
      FOUND=1
    fi
  done
done
if [ "$CONFIG_FOUND" -eq 0 ]; then
  log "No common per-user container runtime/config folders found."
  log "What this means: the script did not find common Docker, Podman, Colima, Lima, Rancher Desktop, or OrbStack user configuration/state folders under /Users."
fi

log ""
log "Checking actual containers where supported..."

if command -v docker >/dev/null 2>&1; then
  CONTAINER_RUNTIME_CHECKED=1
  DOCKER_CONTAINERS=$(docker ps -a --format '{{.ID}} {{.Image}} {{.Status}}' 2>/dev/null)
  if [ -n "$DOCKER_CONTAINERS" ]; then
    log "Docker containers found:"
    echo "$DOCKER_CONTAINERS"
    CONTAINER_INSTANCE_FOUND=1
    FOUND=1
  fi
fi

if command -v podman >/dev/null 2>&1; then
  CONTAINER_RUNTIME_CHECKED=1
  PODMAN_CONTAINERS=$(podman ps -a --format '{{.ID}} {{.Image}} {{.Status}}' 2>/dev/null)
  if [ -n "$PODMAN_CONTAINERS" ]; then
    log "Podman containers found:"
    echo "$PODMAN_CONTAINERS"
    CONTAINER_INSTANCE_FOUND=1
    FOUND=1
  fi
fi

if command -v nerdctl >/dev/null 2>&1; then
  CONTAINER_RUNTIME_CHECKED=1
  NERDCTL_CONTAINERS=$(nerdctl ps -a 2>/dev/null)
  if echo "$NERDCTL_CONTAINERS" | grep -qv '^CONTAINER ID'; then
    log "nerdctl/containerd containers found:"
    echo "$NERDCTL_CONTAINERS"
    CONTAINER_INSTANCE_FOUND=1
    FOUND=1
  fi
fi

if command -v container >/dev/null 2>&1; then
  CONTAINER_RUNTIME_CHECKED=1
  APPLE_CONTAINER_OUTPUT=$(container list 2>/dev/null)
  if [ -n "$APPLE_CONTAINER_OUTPUT" ]; then
    log "Apple Container output:"
    echo "$APPLE_CONTAINER_OUTPUT"
    CONTAINER_INSTANCE_FOUND=1
    FOUND=1
  fi
fi
if [ "$CONTAINER_INSTANCE_FOUND" -eq 0 ]; then
  if [ "$CONTAINER_RUNTIME_CHECKED" -eq 1 ]; then
    log "No container instances were returned by the supported runtime commands that were available."
    log "What this means: the device may have container tooling installed, but this script did not find created, stopped, or running containers through docker, podman, nerdctl, or Apple Container."
  else
    log "No supported container runtime CLI was available for container instance enumeration."
    log "What this means: without docker, podman, nerdctl, or Apple Container CLI access, the script cannot query actual container instances."
  fi
fi

finish_detection
