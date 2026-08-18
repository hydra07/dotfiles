#!/usr/bin/env bash
# =============================================================================
# install.sh — Dotfiles bootstrap for Linux (apt/pacman/dnf) & macOS (brew)
#
#   [1/5] OS packages   — git/curl/build tools/fish/kitty/neovim/starship/...
#   [2/5] mise          — installed via https://mise.run if missing
#   [3/5] Linker        — dotfiles/.config/<pkg>/ → ~/.config/<pkg>/ (TUI)
#   [4/5] mise install  — provisions [tools] from the now-linked config.toml
#   [5/5] Shell         — fisher sync + optional `chsh -s fish`
#
# Package manager is auto-detected (apt/pacman/dnf/brew) — nothing here is
# locked to one distro; only a handful of package *names* differ per manager.
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_SRC="$DOTFILES_ROOT/.config"
CONFIG_DEST="$HOME/.config"

# ── Palette ───────────────────────────────────────────────────────────────
R='\033[0m'; BOLD='\033[1m'; DIM='\033[2m'
CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'
RED='\033[0;31m'; GRAY='\033[0;90m'; WHITE='\033[1;37m'; BGRAY='\033[100m'

mkdir -p "$CONFIG_DEST"

# ── Small print helpers ──────────────────────────────────────────────────
ok()   { echo -e "   ${GREEN}✓${R} $*"; }
warn() { echo -e "   ${YELLOW}⚠${R} $*"; }
fail() { echo -e "   ${RED}✗${R} $*"; }
info() { echo -e "   ${GRAY}○${R} $*"; }

TOTAL_STEPS=5
STEP_NUM=0
section() {
  STEP_NUM=$((STEP_NUM + 1))
  local title="$1"
  echo
  echo -e "${CYAN}${BOLD}[$STEP_NUM/$TOTAL_STEPS] $title${R}"
  echo -e "${GRAY}$(printf '─%.0s' $(seq 1 62))${R}"
}

banner() {
  echo -e "${CYAN}"
  cat <<'EOF'
   ╭──────────────────────────────────────────────────────────╮
   │                    d o t f i l e s                        │
   │              bootstrap · link · provision                 │
   ╰──────────────────────────────────────────────────────────╯
EOF
  echo -e "${R}${GRAY}   $DOTFILES_ROOT${R}"
}

# Runs a command in the background with a spinner; output is hidden unless
# it fails, in which case the tail of the log is shown for diagnosis.
run_quiet() {
  local label="$1"; shift
  local log; log="$(mktemp)"
  local frames='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
  local i=0 rc

  ("$@" >"$log" 2>&1) &
  local pid=$!

  tput civis 2>/dev/null || true
  while kill -0 "$pid" 2>/dev/null; do
    local f="${frames:i%${#frames}:1}"
    i=$((i + 1))
    printf "\r   ${CYAN}%s${R} %s" "$f" "$label"
    sleep 0.08
  done
  tput cnorm 2>/dev/null || true

  wait "$pid"; rc=$?
  printf "\r\033[K"
  if [[ $rc -eq 0 ]]; then
    ok "$label"
  else
    fail "$label ${GRAY}(exit $rc)${R}"
    sed 's/^/     /' <(tail -n 15 "$log") | while IFS= read -r line; do
      echo -e "${GRAY}${DIM}$line${R}"
    done
  fi
  rm -f "$log"
  return $rc
}

confirm() {
  local prompt="$1" default="${2:-n}" ans
  local hint="y/N"; [[ "$default" == y ]] && hint="Y/n"
  read -rp "$(echo -e "   ${CYAN}?${R} $prompt [$hint]: ")" ans
  ans="${ans:-$default}"
  [[ "${ans,,}" == "y" ]]
}

# =============================================================================
# [1/5] OS packages
# =============================================================================

detect_pm() {
  if command -v apt-get &>/dev/null; then echo apt
  elif command -v pacman &>/dev/null; then echo pacman
  elif command -v dnf &>/dev/null; then echo dnf
  elif command -v brew &>/dev/null; then echo brew
  else echo none
  fi
}

# Generic tool name -> package name for a given manager. Falls back to the
# generic name unchanged when no override is needed (true for most tools —
# git/curl/wget/unzip/fish/neovim/starship/fzf/ripgrep/eza share the same
# package name across apt/pacman/dnf/brew).
pkg_name() {
  local pm="$1" generic="$2"
  case "$pm:$generic" in
    apt:build-tools) echo "build-essential" ;;
    pacman:build-tools) echo "base-devel" ;;
    dnf:build-tools) echo "make gcc gcc-c++" ;;
    brew:build-tools) echo "" ;; # Xcode CLT — not brew-installable, see hint below
    *) echo "$generic" ;;
  esac
}

pkg_present() {
  case "$1" in
    build-tools) command -v gcc &>/dev/null || command -v cc &>/dev/null ;;
    neovim)      command -v nvim &>/dev/null ;;
    ripgrep)     command -v rg &>/dev/null ;;
    *) command -v "$1" &>/dev/null ;;
  esac
}

pkg_install_batch() {
  local pm="$1"; shift
  case "$pm" in
    apt)    sudo apt-get install -y "$@" ;;
    pacman) sudo pacman -S --needed --noconfirm "$@" ;;
    dnf)    sudo dnf install -y "$@" ;;
    brew)   brew install "$@" ;;
  esac
}

# kitty needs a different install shape on brew (cask, not formula) —
# handled on its own instead of forcing it into the generic batch.
install_kitty() {
  if command -v kitty &>/dev/null; then
    info "kitty ${GRAY}(already installed)${R}"; return 0
  fi
  case "$PM" in
    apt)    run_quiet "Installing kitty" sudo apt-get install -y kitty || true ;;
    pacman) run_quiet "Installing kitty" sudo pacman -S --needed --noconfirm kitty || true ;;
    dnf)    run_quiet "Installing kitty" sudo dnf install -y kitty || true ;;
    brew)   run_quiet "Installing kitty" brew install --cask kitty || true ;;
    *)      warn "kitty: no package manager detected — install manually: https://sw.kovidgoyal.net/kitty/" ;;
  esac
}

CORE_PKGS=(git curl wget unzip build-tools fish neovim starship fzf ripgrep eza)

install_os_packages() {
  PM="$(detect_pm)"
  if [[ "$PM" == none ]]; then
    warn "No supported package manager found (apt/pacman/dnf/brew) — skipping OS packages."
    return 0
  fi
  info "Package manager: ${WHITE}$PM${R}"

  local keepalive_pid=""
  if [[ "$PM" != brew ]]; then
    echo -e "   ${GRAY}sudo is needed to install system packages — you may be prompted once.${R}"
    if ! sudo -v; then
      warn "No sudo access — skipping OS packages."
      return 0
    fi
    ( while true; do sleep 60; sudo -n true 2>/dev/null || exit; done ) &
    keepalive_pid=$!
  fi

  case "$PM" in
    apt)  run_quiet "Refreshing apt package index" sudo apt-get update -y || true ;;
    brew) run_quiet "Updating brew" brew update || true ;;
    *)    ;;
  esac

  local missing=()
  for generic in "${CORE_PKGS[@]}"; do
    if pkg_present "$generic"; then
      info "$generic ${GRAY}(already installed)${R}"
      continue
    fi
    local name; name="$(pkg_name "$PM" "$generic")"
    if [[ -z "$name" ]]; then
      warn "$generic: no $PM package — install manually (e.g. \`xcode-select --install\`)"
      continue
    fi
    # shellcheck disable=SC2206
    missing+=($name)
  done

  if [[ ${#missing[@]} -gt 0 ]]; then
    run_quiet "Installing: ${missing[*]}" pkg_install_batch "$PM" "${missing[@]}" || true
  else
    ok "All core packages already present."
  fi

  install_kitty

  [[ -n "$keepalive_pid" ]] && kill "$keepalive_pid" 2>/dev/null || true
}

# =============================================================================
# [2/5] mise
# =============================================================================

install_mise() {
  if command -v mise &>/dev/null; then
    ok "mise already installed (${GRAY}$(mise --version | awk '{print $1, $2}')${R})"
    return 0
  fi
  run_quiet "Installing mise (mise.run)" bash -c 'curl -fsSL https://mise.run | sh' || true
  export PATH="$HOME/.local/bin:$PATH"
  if command -v mise &>/dev/null; then
    ok "mise installed"
  else
    fail "mise installed but not on PATH — add ~/.local/bin to PATH and re-run"
  fi
}

# =============================================================================
# [3/5] Linker — unchanged interactive TUI
# =============================================================================

cleanup_stale_links() {
  local stale=()
  while IFS= read -r -d '' link; do
    stale+=("$link")
  done < <(find "$CONFIG_DEST" -maxdepth 1 -type l -print0)

  [[ ${#stale[@]} -eq 0 ]] && return 0

  echo -e "${YELLOW}[!] Found ${#stale[@]} symlink(s) in ~/.config:${R}"
  for s in "${stale[@]}"; do
    echo -e "    ${GRAY}- $(basename "$s") -> $(readlink "$s")${R}"
  done
  read -rp "    Remove all? [Y/n]: " choice
  [[ "${choice,,}" == "n" ]] && { echo -e "    ${YELLOW}[!] Skipped.${R}"; return 0; }
  for s in "${stale[@]}"; do rm "$s"; done
  echo -e "    ${GREEN}[✓] Cleaned.${R}"
}

SELECTED_INDICES=()
show_menu() {
  local -n _items=$1
  local title="${2:-SELECT ITEMS}"
  local count=${#_items[@]}
  local cur=0
  local -a sel=()
  for ((i = 0; i < count; i++)); do sel[$i]=0; done

  tput civis
  trap 'tput cnorm' EXIT INT TERM

  echo -e "\n${CYAN}--- $title ---${R}"
  echo -e "${GRAY}[↑↓/jk] Nav  [Space] Toggle  [a] All  [Enter] Confirm  [q/Esc] Cancel${R}\n"
  for ((i = 0; i < count; i++)); do echo ""; done
  tput cuu "$count"

  _render() {
    tput cuu "$count"
    for ((i = 0; i < count; i++)); do
      local name="${_items[$i]}" mark="[ ]"
      [[ ${sel[$i]} -eq 1 ]] && mark="[x]"
      tput el
      if [[ $i -eq $cur ]]; then
        [[ ${sel[$i]} -eq 1 ]] \
          && echo -e "${BGRAY}${GREEN} $mark $name${R}" \
          || echo -e "${BGRAY}${WHITE} $mark $name${R}"
      else
        [[ ${sel[$i]} -eq 1 ]] \
          && echo -e "${GREEN} $mark $name${R}" \
          || echo -e "${GRAY} $mark $name${R}"
      fi
    done
  }

  _render
  while true; do
    local key; IFS= read -rsn1 key
    if [[ $key == $'\x1b' ]]; then read -rsn2 -t 0.1 rest || true; key="$key$rest"; fi
    case "$key" in
      $'\x1b[A' | k) ((cur > 0)) && ((cur--)) ;;
      $'\x1b[B' | j) ((cur < count - 1)) && ((cur++)) ;;
      ' ') [[ ${sel[$cur]} -eq 1 ]] && sel[$cur]=0 || sel[$cur]=1 ;;
      a | A)
        local all_on=0
        for ((i = 0; i < count; i++)); do [[ ${sel[$i]} -eq 0 ]] && { all_on=1; break; }; done
        for ((i = 0; i < count; i++)); do sel[$i]=$all_on; done ;;
      '' | $'\n')
        tput cnorm; trap - EXIT INT TERM; echo ""
        SELECTED_INDICES=()
        for ((i = 0; i < count; i++)); do [[ ${sel[$i]} -eq 1 ]] && SELECTED_INDICES+=("$i"); done
        return 0 ;;
      $'\x1b' | q | Q) tput cnorm; trap - EXIT INT TERM; echo ""; return 1 ;;
    esac
    _render
  done
}

link_package() {
  local pkg="$1"
  local src="$CONFIG_SRC/$pkg"
  local dest="$CONFIG_DEST/$pkg"

  if [[ -L "$dest" && "$(readlink -f "$dest")" == "$(readlink -f "$src")" ]]; then
    info "Already linked: $pkg"; return
  fi

  if [[ -e "$dest" && ! -L "$dest" ]]; then
    local bak="${dest}.bak"
    [[ -e "$bak" ]] && rm -rf "$bak"
    mv "$dest" "$bak"
    warn "Backed up: $pkg → $pkg.bak"
    BACKED_UP+=("$bak")
  fi

  [[ -L "$dest" ]] && rm "$dest"

  ln -sf "$src" "$dest" && ok "Linked: $pkg" || fail "Failed: $pkg"
}

run_linker() {
  cleanup_stale_links

  mapfile -t PACKAGES < <(find "$CONFIG_SRC" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort)
  if [[ ${#PACKAGES[@]} -eq 0 ]]; then
    warn "No packages found in $CONFIG_SRC"; return 0
  fi

  if ! show_menu PACKAGES "DOTFILES LINKER"; then
    warn "Cancelled — nothing linked."; return 0
  fi
  if [[ ${#SELECTED_INDICES[@]} -eq 0 ]]; then
    warn "No items selected."; return 0
  fi

  echo
  BACKED_UP=()
  for idx in "${SELECTED_INDICES[@]}"; do
    link_package "${PACKAGES[$idx]}"
  done

  if [[ ${#BACKED_UP[@]} -gt 0 ]]; then
    echo
    warn "${#BACKED_UP[@]} backup(s) created:"
    for b in "${BACKED_UP[@]}"; do echo -e "     ${GRAY}- $b${R}"; done
    if confirm "Delete them?" n; then
      for b in "${BACKED_UP[@]}"; do rm -rf "$b"; done
      ok "Backups cleaned."
    fi
  fi
}

# =============================================================================
# [4/5] mise install — provision [tools] from the now-linked config.toml
# =============================================================================

provision_mise_tools() {
  if ! command -v mise &>/dev/null; then
    warn "mise not on PATH — skipping tool provisioning."
    return 0
  fi
  if [[ ! -f "$CONFIG_DEST/mise/config.toml" ]]; then
    info "mise config not linked — skipping tool provisioning."
    return 0
  fi
  mise trust "$CONFIG_DEST/mise/config.toml" &>/dev/null || true
  run_quiet "mise install (node/go/pnpm/bun/...) — first run can take a while" mise install || true
}

# =============================================================================
# [5/5] Shell — fisher sync + optional chsh
# =============================================================================

sync_fisher() {
  if ! command -v fish &>/dev/null; then
    warn "fish not installed — skipping fisher sync."
    return 0
  fi
  if [[ ! -d "$CONFIG_DEST/fish" ]]; then
    info "fish config not linked — skipping fisher sync."
    return 0
  fi
  run_quiet "fisher update (z, fzf.fish, done, fisher)" fish -c 'fisher update' || true
}

offer_chsh() {
  command -v fish &>/dev/null || return 0
  local fish_path; fish_path="$(command -v fish)"

  if [[ "${SHELL:-}" == "$fish_path" ]]; then
    ok "fish is already your default shell."
    return 0
  fi

  if ! grep -qxF "$fish_path" /etc/shells 2>/dev/null; then
    warn "$fish_path is not in /etc/shells — adding it (needs sudo)."
    if ! echo "$fish_path" | sudo tee -a /etc/shells >/dev/null; then
      fail "Could not update /etc/shells — run \`chsh -s $fish_path\` manually."
      return 0
    fi
  fi

  if confirm "Set fish as your default login shell?" n; then
    if chsh -s "$fish_path"; then
      ok "Default shell set to fish — takes effect next login."
    else
      fail "chsh failed — run it manually: chsh -s $fish_path"
    fi
  else
    info "Skipped — run \`chsh -s $fish_path\` anytime."
  fi
}

# =============================================================================
# Main
# =============================================================================

banner

section "OS packages"
install_os_packages

section "mise"
install_mise

section "Dotfiles linker"
run_linker

section "Provisioning tools (mise install)"
provision_mise_tools

section "Shell setup"
sync_fisher
offer_chsh

echo
echo -e "${GREEN}${BOLD}╭──────────────────────────────────────────────────────────╮${R}"
echo -e "${GREEN}${BOLD}│  ✓ Bootstrap complete                                      │${R}"
echo -e "${GREEN}${BOLD}╰──────────────────────────────────────────────────────────╯${R}"
echo -e "${GRAY}   Open a new terminal (or re-login, if the shell changed) to pick up everything.${R}"
echo
