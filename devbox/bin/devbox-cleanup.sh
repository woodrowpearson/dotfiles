#!/bin/zsh
# devbox-cleanup.sh
# Daily cleanup driver. Runs at 03:00 via launchd.
# Env: DRY_RUN=1 prints what would be done; 0 (default) executes.
# Always exits 0; per-step errors are recorded in the report, not propagated as exit codes.

set -u
set -o pipefail
# Allow empty globs to expand to nothing (instead of erroring "no matches found").
# Bare rm patterns like ~/Library/Caches/com.spotify.client/* should silently no-op
# when the cache directory is already empty — that's success, not failure.
setopt NULL_GLOB

DRY_RUN="${DRY_RUN:-0}"
REPORT_DIR="${HOME}/Documents/admin/cleanup-reports"
SNAP_DIR="${HOME}/Documents/admin/system-snapshots"
CACHE_STATE="${HOME}/Library/Caches/devbox-monitor"
mkdir -p "$REPORT_DIR" "$SNAP_DIR" "$CACHE_STATE"

today=$(date +%Y-%m-%d)
report="${REPORT_DIR}/${today}.md"

if [[ -f "$report" ]]; then
  print -- "" >> "$report"
  print -- "---" >> "$report"
  print -- "" >> "$report"
fi

has_cmd() { command -v "$1" >/dev/null 2>&1; }
disk_used_gb() {
  # /System/Volumes/Data is the writable data volume on APFS;
  # `/` is the read-only system volume and never changes.
  /bin/df -k /System/Volumes/Data | awk 'NR==2 {printf "%.1f", $3/1024/1024}'
}
disk_pct() {
  /bin/df -k /System/Volumes/Data | awk 'NR==2 {gsub("%","",$5); print $5}'
}
dir_size_h() {
  [[ -d "$1" ]] && /usr/bin/du -sh "$1" 2>/dev/null | awk '{print $1}' || print -- "0B"
}

declare -a STEPS_DESC STEPS_RESULT STEPS_RECLAIM STEPS_ERR

run_step() {
  local desc="$1"; shift
  local cmd="$*"
  local before after
  before=$(disk_used_gb)
  if (( DRY_RUN )); then
    STEPS_DESC+=("$desc"); STEPS_RESULT+=("DRY"); STEPS_RECLAIM+=("-"); STEPS_ERR+=("(would run: $cmd)")
    return 0
  fi
  # Trust exit code, not stderr presence. Many tools (uv, gh, npm) emit informational
  # stderr messages on no-op runs but exit 0 — those are successes, not failures.
  local err ec
  err=$(eval "$cmd" 2>&1 >/dev/null)
  ec=$?
  after=$(disk_used_gb)
  local reclaim
  reclaim=$(awk -v b="$before" -v a="$after" 'BEGIN { d=b-a; if (d<0) d=0; printf "%.2f GB", d }')
  if (( ec != 0 )); then
    STEPS_DESC+=("$desc"); STEPS_RESULT+=("ERR"); STEPS_RECLAIM+=("$reclaim"); STEPS_ERR+=("${err:0:200}")
  else
    STEPS_DESC+=("$desc"); STEPS_RESULT+=("OK"); STEPS_RECLAIM+=("$reclaim"); STEPS_ERR+=("")
  fi
}

before_pct=$(disk_pct)
before_gb=$(disk_used_gb)
before_vmbundles=$(dir_size_h "$HOME/Library/Application Support/Claude/vm_bundles")
before_npm=$(dir_size_h "$HOME/.npm")
before_dd=$(dir_size_h "$HOME/Library/Developer/Xcode/DerivedData")

{
  print -- "# Cleanup report — ${today}$([ "$DRY_RUN" = "1" ] && print -- " (DRY RUN)")"
  print --
  print -- "**Generated:** $(date)"
  print --
  print -- "## Disk before"
  print -- "- root: ${before_pct}% used (${before_gb} GB)"
  print -- "- vm_bundles: ${before_vmbundles}"
  print -- "- npm: ${before_npm}"
  print -- "- DerivedData: ${before_dd}"
  print --
} > "$report"

# Auto-clean tier — first-party CLIs first
print -- "## Auto-clean (first-party CLIs)" >> "$report"
print -- >> "$report"

if has_cmd npm;        then run_step "npm cache clean --force"          'npm cache clean --force'; fi
if has_cmd brew;       then run_step "brew cleanup -s --prune=all"      'brew cleanup -s --prune=all'; fi
if has_cmd uv;         then run_step "uv cache clean"                   'uv cache clean'; fi
if has_cmd pip;        then run_step "pip cache purge"                  'pip cache purge'; fi
if has_cmd pre-commit; then run_step "pre-commit clean"                 'pre-commit clean'; fi
if has_cmd gh;         then run_step "gh cache delete --all"            'gh cache delete --all || true'; fi  # gh exits 1 when no caches
if has_cmd xcrun;      then run_step "xcrun simctl delete unavailable"  'xcrun simctl delete unavailable'; fi

# Auto-clean tier — bare deletes (rm/find override per spec)
run_step "DerivedData wipe"            '/bin/rm -rf "$HOME/Library/Developer/Xcode/DerivedData"/*'
run_step "SwiftPM cache wipe"          '/bin/rm -rf "$HOME/Library/Caches/org.swift.swiftpm"/*'
run_step "todesktop ShipIt wipe"       '/bin/rm -rf "$HOME/Library/Caches/com.todesktop."*/ShipIt'
run_step "claudefordesktop ShipIt wipe" '/bin/rm -rf "$HOME/Library/Caches/com.anthropic.claudefordesktop.ShipIt"'
run_step "Spotify cache wipe"          '/bin/rm -rf "$HOME/Library/Caches/com.spotify.client"/*'
run_step "VSCode CachedExtensionVSIXs" '/bin/rm -rf "$HOME/Library/Application Support/Code/CachedExtensionVSIXs"/*'
run_step "firebase cache wipe"         '/bin/rm -rf "$HOME/.cache/firebase"/*'
run_step "puppeteer cache wipe"        '/bin/rm -rf "$HOME/.cache/puppeteer"/*'
run_step "DiagnosticReports >30d"      '/usr/bin/find "$HOME/Library/Logs/DiagnosticReports" -mtime +30 -delete 2>/dev/null'
run_step "_npx >30d"                   '/usr/bin/find "$HOME/.npm/_npx" -mtime +30 -delete 2>/dev/null'
run_step "old plans >30d"              '/usr/bin/find "$HOME/.claude/plans" -name "*.md" -mtime +30 -delete 2>/dev/null'
# Worktree pruning across user-configured repos (one path per line in ~/.config/devbox/audit-repos.txt)
DEVBOX_AUDIT_CONFIG="${HOME}/.config/devbox/audit-repos.txt"
audit_repos=()
if [[ -f "$DEVBOX_AUDIT_CONFIG" ]]; then
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%%#*}"  # strip comments
    line="${line## }"; line="${line%% }"  # trim
    [[ -z "$line" ]] && continue
    # Note: must escape ~ in the strip pattern, otherwise zsh tilde-expands it
    # to $HOME before matching, and the literal ~/ prefix is never stripped.
    [[ "$line" = '~/'* ]] && line="${HOME}/${line#\~/}"
    audit_repos+=("$line")
  done < "$DEVBOX_AUDIT_CONFIG"
fi
if (( ${#audit_repos[@]} == 0 )); then
  STEPS_DESC+=("git worktree prune (no repos configured)"); STEPS_RESULT+=("OK"); STEPS_RECLAIM+=("-"); STEPS_ERR+=("(create $DEVBOX_AUDIT_CONFIG to enable)")
else
  for repo in "${audit_repos[@]}"; do
    repo_label="$(basename "$repo")"
    run_step "git worktree prune ($repo_label)" "git -C \"$repo\" worktree prune 2>&1"
  done
fi

# Step 20: refresh RSS baseline
if (( DRY_RUN == 0 )); then
  baseline_file="${CACHE_STATE}/baseline-rss.tsv"
  ts=$(date +%s)
  ps -axo comm,rss 2>/dev/null | awk -v ts="$ts" 'NR>1 {print $1"\t"$2"\t"ts}' >> "${baseline_file}.raw"
  cutoff=$((ts - 7*86400))
  awk -v c="$cutoff" '$3 >= c' "${baseline_file}.raw" > "${baseline_file}.tmp" && mv "${baseline_file}.tmp" "${baseline_file}.raw"
  awk '
    { vals[$1] = vals[$1] " " $2 }
    END {
      for (cmd in vals) {
        n = split(vals[cmd], arr, " ")
        delete sorted
        c = 0
        for (i=1; i<=n; i++) if (arr[i] != "") { c++; sorted[c] = arr[i] }
        for (i=1; i<=c; i++) for (j=i+1; j<=c; j++) if (sorted[i]+0 > sorted[j]+0) { t=sorted[i]; sorted[i]=sorted[j]; sorted[j]=t }
        median = sorted[int((c+1)/2)]
        print cmd "\t" median
      }
    }
  ' "${baseline_file}.raw" > "$baseline_file"
fi
STEPS_DESC+=("baseline RSS refresh"); STEPS_RESULT+=("$([ "$DRY_RUN" = "1" ] && print DRY || print OK)"); STEPS_RECLAIM+=("-"); STEPS_ERR+=("")

# Render auto-clean results table here (immediately after auto-clean steps)
{
  print -- "| # | Step | Result | Reclaimed | Notes |"
  print -- "|---|---|---|---|---|"
  i=1
  while (( i <= ${#STEPS_DESC[@]} )); do
    notes="${STEPS_ERR[$i]}"
    notes="${notes//|/\\|}"
    print -- "| $i | ${STEPS_DESC[$i]} | ${STEPS_RESULT[$i]} | ${STEPS_RECLAIM[$i]} | ${notes} |"
    i=$((i + 1))
  done
  print --
} >> "$report"

# Ask-first queue
print -- "## Ask-first queue (run /cleanup-review to process)" >> "$report"
print -- >> "$report"

# A. Worktrees across user-configured repos (uses audit_repos[] computed earlier)
print -- "### Worktrees" >> "$report"
if (( ${#audit_repos[@]} == 0 )); then
  print -- "(no repos configured — see $DEVBOX_AUDIT_CONFIG)" >> "$report"
else
  for repo in "${audit_repos[@]}"; do
    cards=$(~/.local/bin/devbox-worktree-audit.sh "$repo" 2>/dev/null)
    if [[ -n "$cards" ]]; then
      print -- "**$(basename "$repo"):**" >> "$report"
      print -- "$cards" >> "$report"
    fi
  done
  # If nothing was emitted across all repos:
  if ! /usr/bin/grep -q '^- branch:' "$report" 2>/dev/null; then
    print -- "(none — no worktrees ≥14d stale across configured repos)" >> "$report"
  fi
fi
print -- >> "$report"

# B. ~/.claude/projects dirs ≥30d, no matching active worktree path
print -- "### ~/.claude/projects (Claude session metadata)" >> "$report"
# Active-worktree-path slugs across all configured repos (Claude project dir names mirror worktree paths)
active_worktree_slugs=""
for repo in "${audit_repos[@]}"; do
  active_worktree_slugs+="$(git -C "$repo" worktree list --porcelain 2>/dev/null | awk '/^worktree / {print $2}' | sed 's|/|-|g')"$'\n'
done
/usr/bin/find "$HOME/.claude/projects" -mindepth 1 -maxdepth 1 -type d -mtime +30 2>/dev/null | while read d; do
  base=$(basename "$d")
  if print -- "$active_worktree_slugs" | grep -qF "$base"; then
    continue
  fi
  size_h=$(/usr/bin/du -sh "$d" | awk '{print $1}')
  mtime=$(/usr/bin/stat -f "%Sm" -t "%Y-%m-%d" "$d")
  print -- "- path: \`$d\`"
  print -- "  size: $size_h"
  print -- "  last_modified: $mtime"
  print -- "  recommendation: SAFE (≥30d stale, no active worktree)"
  print --
done >> "$report"

# C. Claude vm_bundles ≥7d AND Claude.app not running
print -- "### Claude vm_bundles" >> "$report"
if pgrep -i "Claude.app" >/dev/null 2>&1; then
  print -- "(skipped — Claude.app is currently running)" >> "$report"
else
  vmd="$HOME/Library/Application Support/Claude/vm_bundles"
  if [[ -d "$vmd" ]]; then
    /usr/bin/find "$vmd" -mindepth 1 -maxdepth 1 -type d -mtime +7 2>/dev/null | while read d; do
      size_h=$(/usr/bin/du -sh "$d" | awk '{print $1}')
      mtime=$(/usr/bin/stat -f "%Sm" -t "%Y-%m-%d" "$d")
      print -- "- bundle: \`$(basename "$d")\`"
      print -- "  size: $size_h"
      print -- "  last_modified: $mtime"
      print -- "  recommendation: SAFE to delete (≥7d, no active session)"
      print --
    done >> "$report"
  fi
fi

# D. ~/.cache/huggingface if >2GB AND last access ≥30d
print -- "### Hugging Face cache" >> "$report"
hf="$HOME/.cache/huggingface"
if [[ -d "$hf" ]]; then
  size_kb=$(/usr/bin/du -sk "$hf" | awk '{print $1}')
  if (( size_kb > 2000000 )); then
    last_access=$(/usr/bin/stat -f "%a" "$hf")
    now_e=$(date +%s)
    age_days=$(( (now_e - last_access) / 86400 ))
    if (( age_days >= 30 )); then
      size_h=$(/usr/bin/du -sh "$hf" | awk '{print $1}')
      print -- "- path: \`$hf\`"
      print -- "  size: $size_h"
      print -- "  last_access: ${age_days}d ago"
      print -- "  recommendation: REVIEW (re-downloads on next use)"
    else
      print -- "(skipped — accessed ${age_days}d ago, <30d threshold)"
    fi
  else
    print -- "(skipped — under 2 GB threshold)"
  fi
fi >> "$report"
print -- >> "$report"

# E. Documents files >100MB AND >28d → propose iCloud move
print -- "### Documents → iCloud (large + old files)" >> "$report"
icloud_target_root="$HOME/Library/Mobile Documents/com~apple~CloudDocs/admin/archive/Documents"
/usr/bin/find "$HOME/Documents" -type f -size +100M -mtime +28 2>/dev/null | while read f; do
  size_h=$(/usr/bin/du -sh "$f" | awk '{print $1}')
  rel="${f#$HOME/Documents/}"
  target="${icloud_target_root}/${rel}"
  print -- "- source: \`$f\`"
  print -- "  size: $size_h"
  print -- "  target: \`$target\`"
  print -- "  recommendation: MOVE to iCloud"
  print --
done >> "$report"

# F. Xcode Archives >90d
print -- "### Xcode Archives (>90d)" >> "$report"
arc="$HOME/Library/Developer/Xcode/Archives"
if [[ -d "$arc" ]]; then
  /usr/bin/find "$arc" -mindepth 1 -maxdepth 2 -type d -mtime +90 2>/dev/null | while read d; do
    size_h=$(/usr/bin/du -sh "$d" | awk '{print $1}')
    mtime=$(/usr/bin/stat -f "%Sm" -t "%Y-%m-%d" "$d")
    print -- "- archive: \`$d\`"
    print -- "  size: $size_h"
    print -- "  last_modified: $mtime"
    print -- "  recommendation: SAFE to delete"
    print --
  done >> "$report"
fi

# G. System snapshots since last cleanup report
print -- "## System snapshots since last report" >> "$report"
yesterday=$(date -v-1d +%Y-%m-%d 2>/dev/null || date +%Y-%m-%d)
prev_report="${REPORT_DIR}/${yesterday}.md"
if [[ -f "$prev_report" ]]; then
  prev_epoch=$(/usr/bin/stat -f "%m" "$prev_report")
else
  prev_epoch=$(($(date +%s) - 86400))
fi
/usr/bin/find "$SNAP_DIR" -maxdepth 1 -name '*.md' -newer "$prev_report" 2>/dev/null | sort | while read s; do
  fname=$(basename "$s")
  trig="${fname##*_}"; trig="${trig%.md}"
  ts="${fname%_*}"
  print -- "- \`$ts\` ${trig} (file: \`system-snapshots/$fname\`)"
done >> "$report"
print -- >> "$report"

after_pct=$(disk_pct)
after_gb=$(disk_used_gb)
delta_gb=$(awk -v b="$before_gb" -v a="$after_gb" 'BEGIN { printf "%.2f", b-a }')

{
  print -- "## Disk after"
  print -- "- root: ${after_pct}% used (${after_gb} GB)"
  print -- "- reclaimed: ${delta_gb} GB"
  print --
  print -- "## Notes"
  print -- "- Run \`/cleanup-review\` to process the ask-first queue (worktrees, vm_bundles, etc.)."
  print -- "- Run \`/reclaim\` if you want to act on system snapshots."
} >> "$report"

print -- "cleanup complete: report at $report (delta: ${delta_gb} GB)"
exit 0
