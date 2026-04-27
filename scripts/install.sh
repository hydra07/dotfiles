#!/usr/bin/env bash
# =============================================================================
# setup.sh — Dotfiles linker for Linux (Arch)
# Links: dotfiles/.config/<pkg>/ → ~/.config/<pkg>/
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_SRC="$DOTFILES_ROOT/.config"
CONFIG_DEST="$HOME/.config"

R='\033[0m'; CYAN='\033[0;36m'; GREEN='\033[0;32m'
YELLOW='\033[0;33m'; RED='\033[0;31m'; GRAY='\033[0;90m'
WHITE='\033[1;37m'; BGRAY='\033[100m'

mkdir -p "$CONFIG_DEST"

# ── Clean flat/stale symlinks in ~/.config ───────────────────────────────────
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

# ── TUI multi-select ─────────────────────────────────────────────────────────
SELECTED_INDICES=()
show_menu() {
  local -n _items=$1
  local title="${2:-SELECT ITEMS}"
  local count=${#_items[@]}
  local cur=0
  local -a sel=()
  for ((i=0; i<count; i++)); do sel[$i]=0; done

  tput civis
  trap 'tput cnorm' EXIT INT TERM

  echo -e "\n${CYAN}--- $title ---${R}"
  echo -e "${GRAY}[↑↓/jk] Nav  [Space] Toggle  [a] All  [Enter] Confirm  [q/Esc] Cancel${R}\n"
  for ((i=0; i<count; i++)); do echo ""; done
  tput cuu "$count"

  _render() {
    tput cuu "$count"
    for ((i=0; i<count; i++)); do
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
      $'\x1b[A'|k) (( cur > 0 )) && (( cur-- )) ;;
      $'\x1b[B'|j) (( cur < count-1 )) && (( cur++ )) ;;
      ' ') [[ ${sel[$cur]} -eq 1 ]] && sel[$cur]=0 || sel[$cur]=1 ;;
      a|A)
        local all_on=0
        for ((i=0; i<count; i++)); do [[ ${sel[$i]} -eq 0 ]] && { all_on=1; break; }; done
        for ((i=0; i<count; i++)); do sel[$i]=$all_on; done ;;
      ''|$'\n')
        tput cnorm; trap - EXIT INT TERM; echo ""
        SELECTED_INDICES=()
        for ((i=0; i<count; i++)); do [[ ${sel[$i]} -eq 1 ]] && SELECTED_INDICES+=("$i"); done
        return 0 ;;
      $'\x1b'|q|Q) tput cnorm; trap - EXIT INT TERM; echo ""; return 1 ;;
    esac
    _render
  done
}

# ── Link one package ─────────────────────────────────────────────────────────
# Creates: ~/.config/<pkg> -> dotfiles/.config/<pkg>
link_package() {
  local pkg="$1"
  local src="$CONFIG_SRC/$pkg"
  local dest="$CONFIG_DEST/$pkg"

  # Already correct?
  if [[ -L "$dest" && "$(readlink -f "$dest")" == "$(readlink -f "$src")" ]]; then
    echo -e "   ${GRAY}[=] Already linked: $pkg${R}"; return
  fi

  # Backup if real dir exists
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    local bak="${dest}.bak"
    [[ -e "$bak" ]] && rm -rf "$bak"
    mv "$dest" "$bak"
    echo -e "   ${YELLOW}[!] Backed up: $pkg → $pkg.bak${R}"
    BACKED_UP+=("$bak")
  fi

  # Remove stale symlink
  [[ -L "$dest" ]] && rm "$dest"

  ln -sf "$src" "$dest" \
    && echo -e "   ${GREEN}[+] Linked: $pkg${R}" \
    || echo -e "   ${RED}[!] Failed: $pkg${R}"
}

# ── Main ─────────────────────────────────────────────────────────────────────
echo -e "${CYAN}Dotfiles: $DOTFILES_ROOT${R}"

cleanup_stale_links

mapfile -t PACKAGES < <(find "$CONFIG_SRC" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort)
[[ ${#PACKAGES[@]} -eq 0 ]] && { echo -e "${YELLOW}[!] No packages found.${R}"; exit 0; }

if ! show_menu PACKAGES "DOTFILES LINKER"; then
  echo -e "\n${YELLOW}>> Cancelled.${R}"; exit 0
fi
[[ ${#SELECTED_INDICES[@]} -eq 0 ]] && { echo -e "\n${YELLOW}>> No items selected.${R}"; exit 0; }

echo -e "\n${CYAN}>> Processing ${#SELECTED_INDICES[@]} item(s)...${R}"
BACKED_UP=()
for idx in "${SELECTED_INDICES[@]}"; do
  link_package "${PACKAGES[$idx]}"
done

echo -e "\n${CYAN}>> Linking complete.${R}"

if [[ ${#BACKED_UP[@]} -gt 0 ]]; then
  echo -e "\n${YELLOW}[?] ${#BACKED_UP[@]} backup(s) created:${R}"
  for b in "${BACKED_UP[@]}"; do echo -e "    ${GRAY}- $b${R}"; done
  read -rp "    Delete them? [y/N]: " c
  if [[ "${c,,}" == "y" ]]; then
    for b in "${BACKED_UP[@]}"; do rm -rf "$b"; done
    echo -e "    ${GREEN}[✓] Cleaned.${R}"
  fi
fi

echo -e "\n${GREEN}✓ Done.${R}"
