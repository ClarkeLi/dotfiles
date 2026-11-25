# Workflow

## Quick start for a new session
1. Read `CLAUDE.md` (conventions and pitfalls).
2. Update the backup: `./backup.sh`, review `git diff`, commit, push.
3. Restore on a Mac: `./install.sh --dry-run`, then `./install.sh`.

## Status log
- 2026-11-25: Initial backup. `backup.sh`, `install.sh`, `Brewfile`, README. Tested in a temporary home:
  file copy, pinned plugin clones, zsh startup, tmux config parsing, Neovim plugin restore.
  Not tested: full `install.sh` (Homebrew, Claude Code plugins, Lumen build) on a clean Mac.
