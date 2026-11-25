# Conventions and pitfalls

- This repo is **public**. Never commit tokens, keys, histories, private project names or proxy configs.
- `home/` is generated: edit the live config on the Mac, then run `./backup.sh`. Hand edits in `home/` get overwritten.
- Add or remove tracked paths in `files.txt` (used by both `backup.sh` and `install.sh`).
- `private.patterns` is git-ignored and filters private lines out of `.zshrc`. Recreate it on a new clone
  before running `backup.sh`.
- Lumen hooks are stripped from `settings.json` on purpose; Lumen writes them on first launch.
- Scripts must run on the system bash 3.2.
- Test the installer against a throwaway home: `HOME=<tmp dir> ./install.sh --files-only`.
- Commit author is Clarke Li only; no Co-Authored-By lines.
