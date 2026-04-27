#!/bin/zsh
# install.sh — idempotent installer for the dev box observability system.
# Re-running is safe: symlinks are replaced (-sfn); templated configs are
# re-rendered; launchd jobs re-bootstrapped.
#
# Manual prerequisite (one-time, can't be scripted):
#   System Settings → Privacy & Security → Full Disk Access → + → ⌘⇧G → /bin/zsh
#   Without this, LaunchAgents cannot write to ~/Documents/.

set -e
set -u

SRC="${HOME}/dotfiles/devbox"
[[ -d "$SRC" ]] || { print -u2 -- "missing source dir: $SRC"; exit 1; }

# Render @HOME@ placeholders in tracked source → real path at install time.
# Plists and glances.conf can't expand env vars at runtime, so we materialize
# them. Scripts use $HOME at runtime so they're symlinked instead.
render() {
  local src="$1" dst="$2"
  # CRITICAL: remove $dst first. If it's a symlink back to $src (from a previous
  # symlink-style install), `> $dst` would write through it and clobber the source.
  /bin/rm -f "$dst"
  /usr/bin/sed "s|@HOME@|${HOME}|g" "$src" > "$dst"
}

print -- "→ ensuring runtime directories exist"
mkdir -p \
  ~/Documents/admin/cleanup-reports \
  ~/Documents/admin/system-snapshots \
  ~/Library/Caches/devbox-monitor \
  "$HOME/Library/Mobile Documents/com~apple~CloudDocs/admin/archive/Documents" \
  ~/.local/bin \
  ~/.config/glances \
  ~/.config/devbox \
  ~/Library/LaunchAgents \
  ~/Library/Logs

print -- "→ symlinking scripts into ~/.local/bin/"
for s in devbox-snapshot.sh devbox-cleanup.sh devbox-worktree-audit.sh devbox-verify.sh; do
  /bin/ln -sfn "${SRC}/bin/${s}" "${HOME}/.local/bin/${s}"
done

print -- "→ rendering glances config (templated paths)"
render "${SRC}/glances/glances.conf" "${HOME}/.config/glances/glances.conf"

print -- "→ rendering launchd plists (templated paths)"
for p in com.user.devbox-cleanup.plist com.user.devbox-verify.plist; do
  render "${SRC}/launchd/${p}" "${HOME}/Library/LaunchAgents/${p}"
  plutil -lint "${HOME}/Library/LaunchAgents/${p}" >/dev/null
done

print -- "→ creating audit-repos config stub if missing"
if [[ ! -f "${HOME}/.config/devbox/audit-repos.txt" ]]; then
  cat > "${HOME}/.config/devbox/audit-repos.txt" <<'STUB'
# devbox-cleanup will run `git worktree prune` and audit stale worktrees
# (≥14d, clean, has upstream) for every absolute repo path listed below.
# One path per line. Lines starting with # are ignored.
# Example:
#   ~/code/my-project
STUB
  print -- "  → created stub at ~/.config/devbox/audit-repos.txt — edit to enable worktree audit"
fi

print -- "→ (re-)bootstrapping launchd jobs"
launchctl bootout gui/$(id -u)/com.user.devbox-cleanup 2>/dev/null || true
launchctl bootout gui/$(id -u)/com.user.devbox-verify  2>/dev/null || true
launchctl bootstrap gui/$(id -u) "${HOME}/Library/LaunchAgents/com.user.devbox-cleanup.plist"
launchctl bootstrap gui/$(id -u) "${HOME}/Library/LaunchAgents/com.user.devbox-verify.plist"

print -- ""
print -- "✓ install complete"
print -- ""
print -- "Cleanup runs daily at 03:00; verifier at 04:00."
print -- "Reports:    ~/Documents/admin/cleanup-reports/<YYYY-MM-DD>.md"
print -- "Snapshots:  ~/Documents/admin/system-snapshots/<ts>_<trigger>.md"
print -- "Verify log: ~/Library/Logs/devbox-verify.log"
print -- "Repos to audit: edit ~/.config/devbox/audit-repos.txt"
print -- ""
print -- "If LaunchAgent reports never appear: grant Full Disk Access to /bin/zsh"
print -- "  System Settings → Privacy & Security → Full Disk Access → + → ⌘⇧G → /bin/zsh"
print -- ""
print -- "To run cleanup driver now:    ~/.local/bin/devbox-cleanup.sh"
print -- "To run verifier now:          ~/.local/bin/devbox-verify.sh"
print -- "To launch glances panel:      glances"
