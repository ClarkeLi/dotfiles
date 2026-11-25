#!/bin/bash
# Restore this terminal setup on a Mac. Safe to re-run.
# Anything it would overwrite is moved to ~/.dotfiles-backup/<timestamp>/ first.
set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
DRY=0
FILES_ONLY=0
FAILED=""

usage() {
  cat <<'EOF'
Usage: ./install.sh [--dry-run] [--files-only]
  --dry-run     print what would happen, change nothing
  --files-only  copy config files only (no Homebrew, plugins, apps or macOS defaults)
EOF
}
for a in "$@"; do
  case "$a" in
    --dry-run) DRY=1 ;;
    --files-only) FILES_ONLY=1 ;;
    -h|--help) usage; exit 0 ;;
    *) usage; exit 2 ;;
  esac
done

step() { printf '\n\033[1;38;2;249;38;114m==>\033[0m \033[1m%s\033[0m\n' "$*"; }
run() { if [ "$DRY" = 1 ]; then printf '  [dry-run] %s\n' "$*"; else "$@"; fi; }
# Optional step: record the failure and carry on.
try() { run "$@" || { FAILED="$FAILED\n  - $*"; printf '  warning: failed: %s\n' "$*" >&2; }; }
has() { command -v "$1" >/dev/null 2>&1; }

[ "$(uname)" = Darwin ] || { echo "This setup targets macOS." >&2; exit 1; }

copy_files() {
  step "Copying config files into $HOME"
  local p rel src dst
  while IFS= read -r p; do
    case "$p" in ''|'#'*) continue ;; esac
    rel="${p%/}"; src="$REPO/home/$rel"; dst="$HOME/$rel"
    [ -e "$src" ] || { echo "  missing in repo: $rel" >&2; exit 1; }
    if [ -e "$dst" ] || [ -L "$dst" ]; then
      if diff -rq -x .DS_Store -x .git "$src" "$dst" >/dev/null 2>&1; then continue; fi
      run mkdir -p "$BACKUP/$(dirname "$rel")"
      run mv "$dst" "$BACKUP/$rel"
    fi
    echo "  ~/$rel"
    run mkdir -p "$(dirname "$dst")"
    run cp -pR "$src" "$dst"
  done < "$REPO/files.txt"
}

clone_plugins() {
  step "Oh My Zsh, zsh plugins and tmux plugins (pinned in versions.lock)"
  local dir url commit
  while read -r dir url commit; do
    case "$dir" in ''|'#'*) continue ;; esac
    if [ -d "$HOME/$dir/.git" ]; then echo "  keeping existing ~/$dir"; continue; fi
    try git clone --quiet "$url" "$HOME/$dir" </dev/null
    try git -C "$HOME/$dir" checkout --quiet "$commit" </dev/null
  done < "$REPO/versions.lock"
}

if [ "$FILES_ONLY" = 0 ]; then
  has brew || [ ! -x /opt/homebrew/bin/brew ] || eval "$(/opt/homebrew/bin/brew shellenv)"
  has brew || {
    echo "Homebrew is required. Install it from https://brew.sh and run this again." >&2
    exit 1
  }
  step "Homebrew packages"
  try brew bundle --file="$REPO/Brewfile" --no-upgrade
  clone_plugins
fi

copy_files

if [ "$FILES_ONLY" = 0 ]; then
  step "macOS: key repeat instead of the accent popup"
  try defaults write -g ApplePressAndHoldEnabled -bool false

  step "Claude Code, plugins and skills"
  [ -x /opt/homebrew/bin/claude ] || try /opt/homebrew/bin/npm install -g @anthropic-ai/claude-code
  try /opt/homebrew/bin/claude plugin marketplace add anthropics/claude-plugins-official
  for plugin in $(jq -r '.enabledPlugins // {} | to_entries[] | select(.value) | .key' "$REPO/home/.claude/settings.json"); do
    try /opt/homebrew/bin/claude plugin install "$plugin"
  done
  [ -d "$HOME/.claude/skills/apple-design" ] ||
    try npx --yes skills add dickwu/apple-design-skill -g -a claude-code -y

  step "GitHub CLI extension"
  if [ "$DRY" = 1 ] || gh auth status >/dev/null 2>&1; then
    gh extension list 2>/dev/null | grep -q dlvhdr/gh-dash || try gh extension install dlvhdr/gh-dash
  else
    echo "  skipped: run 'gh auth login', then 'gh extension install dlvhdr/gh-dash'"
  fi

  step "Lumen (Claude Code traffic light)"
  if [ -d "$HOME/Applications/Lumen.app" ]; then
    echo "  already installed"
  else
    [ -d "$HOME/.local/src/Lumen" ] ||
      try git clone --quiet https://github.com/ClarkeLi/Lumen.git "$HOME/.local/src/Lumen"
    try bash -c 'cd "$HOME/.local/src/Lumen" && ./build.sh --install'
  fi

  step "Neovim plugins (pinned in lazy-lock.json)"
  # The first launch can bump a few entries while bootstrapping, so put the
  # lockfile back and restore a second time.
  try nvim --headless "+Lazy! restore" +qa
  try cp "$REPO/home/.config/nvim/lazy-lock.json" "$HOME/.config/nvim/lazy-lock.json"
  try nvim --headless "+Lazy! restore" +qa
fi

step "Done"
[ -d "$BACKUP" ] && echo "Previous files were saved in $BACKUP"
[ -n "$FAILED" ] && printf 'These steps failed, check them by hand:%b\n' "$FAILED"
cat <<'EOF'
Next:
  1. Quit and reopen Ghostty, then run: t   (tmux session)
  2. In tmux press Ctrl+b then r to reload the config
  3. Grant Ghostty Accessibility access for the global Ctrl+` quick terminal
  4. Sign in: claude, gh auth login, nvim +"Copilot auth"
EOF
