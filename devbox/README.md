# Dev Box Observability + Cleanup

Personal macOS dev box monitoring and scheduled cache cleanup. Source of truth for the user-level scripts/configs/launchd plists that compose the system. The actual install paths (under `~/.local/bin/`, `~/.config/`, `~/Library/LaunchAgents/`) are symlinks back into this directory.

**Spec:** `~/.claude/specs/2026-04-26-dev-box-observability-cleanup-design.md`
**Plan:** `~/.claude/plans/2026-04-26-dev-box-observability-cleanup.md`
**Slash commands:** `~/.claude/commands/{reclaim,cleanup-review}.md` (lives with the rest of the user's Claude Code config)

## What it does

- **`glances`** TUI shows curated metrics (disk on `/System/Volumes/Data`, mem, swap, load, top procs by RSS)
- **Threshold-triggered snapshots** auto-capture `ps` / `vm_stat` / `iostat` / `df` to `~/Documents/admin/system-snapshots/` when glances detects sustained pressure (mem≥85%, swap≥60%, load≥1.0, fs≥90%). Anti-flap: ≥3 sustained fires + 5-min cooldown per trigger
- **Daily 03:00 cleanup driver** runs 19 first-party-CLI cleanup steps + builds an ask-first queue (stale worktrees, vm_bundles, archives, large old Documents → iCloud). Writes Markdown report to `~/Documents/admin/cleanup-reports/<YYYY-MM-DD>.md`
- **04:00 verifier** sanity-checks the previous run; macOS notification fires only on failure
- **`/reclaim`** Claude command: walks system snapshots with per-PID Y/N gating
- **`/cleanup-review`** Claude command: walks the ask-first queue with per-item Y/N gating

## Layout

```
~/dotfiles/devbox/
├── README.md
├── install.sh                              # idempotent installer
├── bin/
│   ├── devbox-snapshot.sh               # glances threshold action handler
│   ├── devbox-cleanup.sh                # daily driver
│   ├── devbox-worktree-audit.sh         # per-worktree metadata cards (helper)
│   └── devbox-verify.sh                 # 04:00 sanity check
├── glances/
│   └── glances.conf                        # curated panel + threshold actions
└── launchd/
    ├── com.user.devbox-cleanup.plist       # daily 03:00
    └── com.user.devbox-verify.plist        # daily 04:00
```

Install targets:
- `~/.local/bin/devbox-{snapshot,cleanup,worktree-audit,verify}.sh` — **symlinks** back to this dir (scripts use `$HOME` at runtime)
- `~/.config/glances/glances.conf` — **rendered** by `install.sh` (`@HOME@` → real path; plists/glances can't expand env vars)
- `~/Library/LaunchAgents/com.user.devbox-{cleanup,verify}.plist` — **rendered** by `install.sh`
- `~/.config/devbox/audit-repos.txt` — user-specific list of git repos to audit for stale worktrees (gitignored; created as a stub on first install)

The Claude slash commands `/reclaim` and `/cleanup-review` live separately at `~/.claude/commands/`.

## Install on a fresh machine

```bash
cd ~/dotfiles/devbox && ./install.sh
```

Then **manually grant Full Disk Access to `/bin/zsh`**: System Settings → Privacy & Security → Full Disk Access → `+` → `⌘⇧G` → type `/bin/zsh`. Without this, the LaunchAgents can't write to `~/Documents/`.

## Daily flow

1. **03:00** — `com.user.devbox-cleanup` fires; report at `~/Documents/admin/cleanup-reports/<today>.md`
2. **04:00** — `com.user.devbox-verify` fires; if anything failed, you get a `DevBox cleanup verify FAILED` macOS notification
3. **Whenever a glances threshold breaches** — snapshot lands in `~/Documents/admin/system-snapshots/`
4. **Manually** — run `/reclaim` or `/cleanup-review` in Claude Code

## Status logs

- `~/Library/Logs/devbox-cleanup.log` — driver stdout/stderr (latest run)
- `~/Library/Logs/devbox-verify.log` — verifier history (append-only)

## Recovery / reinstall

```bash
cd ~/dotfiles/devbox && ./install.sh
```

Idempotent. Re-runs `ln -sfn` (replaces stale symlinks), re-bootstraps launchd jobs.

## Disable temporarily

```bash
launchctl bootout gui/$(id -u)/com.user.devbox-cleanup
launchctl bootout gui/$(id -u)/com.user.devbox-verify
```

Re-enable: re-run `./install.sh`.

## Configuring worktree audit

The cleanup driver can prune git worktrees and surface stale ones (≥14d clean, has upstream) for any number of repos. List the absolute paths in:

```
~/.config/devbox/audit-repos.txt
```

One path per line; `#` starts a comment. If the file is empty, the worktree section is skipped.

## Operational notes

- **`rm` vs `trash` override:** the auto-clean tier uses `rm -rf` / `find -delete`. Documented override of "always trash"; scoped to the daily driver only. Manual `/cleanup-review` operations use `trash`.
- **APFS volume note:** `df /` is the read-only system volume; the driver measures `/System/Volumes/Data` (the writable data volume) instead.
- **Empty-glob handling:** `setopt NULL_GLOB` lets `rm -rf /already-empty/dir/*` exit 0 silently (otherwise zsh errors with "no matches found").
- **Exit-code-based classification:** `run_step` trusts exit codes, not stderr presence. `gh cache delete --all` is wrapped in `|| true` because gh exits 1 when there are no caches to delete.
- **Templated paths:** plists and glances config can't expand `$HOME` or `~` at runtime. `install.sh` renders `@HOME@` placeholders to absolute paths at install time.
