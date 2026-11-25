#!/bin/bash
# Sync the configs on this Mac into the repo: copy -> sanitise -> secret scan -> swap in.
# Nothing reaches home/ unless the scan passes. Review `git diff` before committing.
set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"
STAGE="$(mktemp -d "$REPO/.stage.XXXXXX")"
trap 'rm -rf "$STAGE"' EXIT

die() { printf 'error: %s\n' "$*" >&2; exit 1; }
command -v jq >/dev/null || die "jq is required"

# ---------- copy ----------
while IFS= read -r p; do
  case "$p" in ''|'#'*) continue ;; esac
  src="$HOME/$p"
  [ -e "$src" ] || die "listed in files.txt but missing: ~/$p"
  mkdir -p "$(dirname "$STAGE/${p%/}")"
  case "$p" in
    */) rsync -a --exclude .git --exclude .DS_Store --exclude __pycache__ "$src" "$STAGE/$p" ;;
    *)  cp -p "$src" "$STAGE/$p" ;;
  esac
done < "$REPO/files.txt"

# ---------- sanitise (only the copies are touched) ----------
zshrc="$STAGE/.zshrc"
# Lines to keep private: one extended regex per line in private.patterns (git-ignored).
if [ -s "$REPO/private.patterns" ]; then
  grep -Ev -f "$REPO/private.patterns" "$zshrc" > "$zshrc.tmp" || true
  cat "$zshrc.tmp" > "$zshrc"; rm "$zshrc.tmp"
else
  echo "warning: private.patterns not found, .zshrc is copied unfiltered" >&2
fi
sed -i '' "s|$HOME/|\$HOME/|g" "$zshrc"
grep -q 'zshrc\.local' "$zshrc" || printf '\n%s\n%s\n' \
  '# machine-specific or private settings (not tracked)' \
  '[[ -r ~/.zshrc.local ]] && source ~/.zshrc.local' >> "$zshrc"

# Do not fail on machines without Rust.
sed -i '' 's|^\. "$HOME/\.cargo/env"$|[ -f "$HOME/.cargo/env" ] \&\& . "$HOME/.cargo/env"|' \
  "$STAGE/.profile" "$STAGE/.bash_profile"

sed -i '' "s|$HOME/|~/|g" "$STAGE/.gitconfig"
sed -i '' -E "s|^working-directory = $HOME/?\$|working-directory = home|" "$STAGE/.config/ghostty/config"

# Claude Code: drop env (may hold API tokens), machine paths, and Lumen's hooks
# (Lumen writes them again on first launch).
settings="$STAGE/.claude/settings.json"
jq '
  .env = {}
  | del(.apiKeyHelper, .sandbox.filesystem)
  | if .hooks then
      .hooks |= (
        with_entries(.value |= (
          map(.hooks |= map(select((.command // "") | contains("ClaudeTrafficLight") | not)))
          | map(select(.hooks | length > 0))))
        | with_entries(select(.value | length > 0)))
    else . end
' "$settings" > "$settings.tmp"
cat "$settings.tmp" > "$settings"; rm "$settings.tmp"

# ---------- secret scan ----------
secrets='sk-[A-Za-z0-9_-]{20,}|gh[pousr]_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|AKIA[0-9A-Z]{16}|AIza[0-9A-Za-z_-]{30,}|xox[abprs]-[A-Za-z0-9-]{10,}|-----BEGIN [A-Z ]*PRIVATE KEY-----|(API_KEY|AUTH_TOKEN|ACCESS_TOKEN|CLIENT_SECRET|PASSWORD)["'\'' ]*[:=] *["'\'']?[A-Za-z0-9_./+-]{8,}'
if grep -rInE -e "$secrets" "$STAGE"; then die "possible secret found (above), nothing was written"; fi
if grep -rInF -e "$HOME/" "$STAGE"; then die "hard-coded home path found (above), nothing was written"; fi

# ---------- swap in ----------
rm -rf "$REPO/home"
mv "$STAGE" "$REPO/home"
chmod 755 "$REPO/home"

# ---------- pin plugin versions ----------
(
  cd "$HOME"
  echo "# <path under \$HOME> <git url> <commit>"
  for d in .oh-my-zsh .oh-my-zsh/custom/plugins/* .tmux/plugins/*; do
    [ -d "$d/.git" ] || continue
    printf '%s %s %s\n' "$d" "$(git -C "$d" remote get-url origin)" "$(git -C "$d" rev-parse HEAD)"
  done
) > "$REPO/versions.lock"

git -C "$REPO" status --short
echo "Done. Review with: git -C \"$REPO\" diff"
