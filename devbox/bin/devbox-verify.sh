#!/bin/zsh
# devbox-verify.sh
# Sanity-checks the previous night's cleanup run. Designed to fire at 04:00 daily
# (1 hour after the 03:00 cleanup driver). Writes a status line to
# ~/Library/Logs/devbox-verify.log and fires a macOS notification ONLY on failure.

set -u
set -o pipefail

today=$(date +%Y-%m-%d)
ts_iso=$(date "+%Y-%m-%dT%H:%M:%S%z")
report="${HOME}/Documents/admin/cleanup-reports/${today}.md"
cleanup_log="${HOME}/Library/Logs/devbox-cleanup.log"
verify_log="${HOME}/Library/Logs/devbox-verify.log"

issues=()

if [[ ! -f "$report" ]]; then
  issues+=("MISSING report at $report — launchd may not have fired or FDA may have lapsed")
else
  # Check log shows successful completion
  if [[ -f "$cleanup_log" ]]; then
    if ! /usr/bin/grep -q "cleanup complete:" "$cleanup_log" 2>/dev/null; then
      issues+=("cleanup-log has no 'cleanup complete' line")
    fi
  else
    issues+=("cleanup log absent at $cleanup_log")
  fi

  # ERR rows in auto-clean table — pull out just the | ERR | lines
  err_rows=$(/usr/bin/grep -E "^\|.*\| ERR \|" "$report" 2>/dev/null || true)
  if [[ -n "$err_rows" ]]; then
    err_count=$(print -- "$err_rows" | /usr/bin/wc -l | /usr/bin/tr -d ' ')
    issues+=("$err_count ERR row(s) in auto-clean table")
  fi

  # Required sections
  for section in "## Auto-clean" "## Ask-first queue" "## Disk after"; do
    if ! /usr/bin/grep -qF "$section" "$report" 2>/dev/null; then
      issues+=("section missing: $section")
    fi
  done

  # Sanity: at least 18 step rows in the auto-clean table
  step_rows=$(/usr/bin/grep -cE "^\| [0-9]+ \|" "$report" 2>/dev/null || echo 0)
  if (( step_rows < 18 )); then
    issues+=("auto-clean table has only $step_rows step rows (expected ≥18)")
  fi
fi

# Always write a log entry
mkdir -p "$(dirname "$verify_log")"
if (( ${#issues[@]} == 0 )); then
  print -- "[$ts_iso] OK — report=$report" >> "$verify_log"
  exit 0
fi

# Failure path: log + notify
print -- "[$ts_iso] FAIL — issues:" >> "$verify_log"
for i in "${issues[@]}"; do
  print -- "  - $i" >> "$verify_log"
done

summary="${#issues[@]} issue(s): ${issues[1]}"
osascript -e "display notification \"${summary}\" with title \"DevBox cleanup verify FAILED\" sound name \"Sosumi\"" 2>/dev/null || true

# Exit 0 so launchd doesn't retry
exit 0
