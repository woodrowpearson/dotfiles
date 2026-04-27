#!/bin/zsh
# devbox-snapshot.sh
# Called by glances threshold actions. Captures a system snapshot with anti-flap throttling.
# Args: $1=trigger (fs|mem|swap|load|cpu) $2=value (numeric) $3=optional extra (e.g. mount point)
# Exits silently (0) if any gate blocks. Writes snapshot to ~/Documents/admin/system-snapshots/.

set -u
set -o pipefail

trigger="${1:-}"
value="${2:-}"
extra="${3:-}"

if [[ -z "$trigger" || -z "$value" ]]; then
  print -u2 -- "usage: $0 <trigger> <value> [extra]"
  exit 2
fi

# Glances 4.5.x doesn't substitute {{percent}} / {{mnt_point}} / {{value}} in
# action_repeat templates — the script receives them literally. Detect this and
# look up the actual current value from system state.
if [[ "$value" == "{{"* ]]; then
  case "$trigger" in
    fs)
      # Highest-used mount across visible volumes (glances hide regex limits the watched set)
      lookup=$(/bin/df -P / "/System/Volumes/Data" 2>/dev/null | awk '
        NR>1 { gsub("%","",$5); if ($5+0 > max) { max=$5+0; mnt=$6 } }
        END  { printf "%s %s", max, mnt }
      ')
      value="${lookup% *}"
      [[ "$extra" == "{{"* || -z "$extra" ]] && extra="${lookup#* }"
      ;;
    mem)
      free_pct=$(memory_pressure 2>/dev/null | awk '/free percentage/ {gsub("%",""); print $NF}')
      [[ -n "$free_pct" ]] && value=$(( 100 - free_pct ))
      ;;
    swap)
      value=$(sysctl -n vm.swapusage 2>/dev/null | awk '
        {
          for (i=1; i<=NF; i++) {
            if ($i=="total") { gsub("M","",$(i+2)); total=$(i+2)+0 }
            if ($i=="used")  { gsub("M","",$(i+2)); used=$(i+2)+0 }
          }
          if (total>0) printf "%.1f", used/total*100; else print "0"
        }')
      ;;
    load)
      # vm.loadavg format: "{ 1.20 1.50 1.80 }"  → $2=1m, $3=5m, $4=15m
      value=$(sysctl -n vm.loadavg 2>/dev/null | awk '{print $2}')
      ;;
  esac
fi

CACHE_DIR="${HOME}/Library/Caches/devbox-monitor"
SNAP_DIR="${HOME}/Documents/admin/system-snapshots"
mkdir -p "$CACHE_DIR" "$SNAP_DIR"

now_epoch=$(date +%s)

# Gate 1: boot gate — uptime <5 min => skip
boot_epoch=$(sysctl -n kern.boottime 2>/dev/null | sed -n 's/.*sec = \([0-9]*\).*/\1/p')
if [[ -n "$boot_epoch" ]] && (( now_epoch - boot_epoch < 300 )); then
  exit 0
fi

# Gate 2: cleanup-window exclusion — 02:55–03:30 inclusive
hhmm=$(date +%H%M)
hhmm=${hhmm##0}  # strip leading zero so arithmetic comparison works
if (( hhmm >= 255 && hhmm <= 330 )); then
  exit 0
fi

# Gate 3: sustained-fire — require ≥3 fires in last 30s
streak_file="${CACHE_DIR}/streak-${trigger}"
last_fire_ts=0
streak=0
if [[ -f "$streak_file" ]]; then
  read last_fire_ts streak < "$streak_file"
fi
if (( now_epoch - last_fire_ts > 30 )); then
  streak=0  # reset stale streak
fi
streak=$((streak + 1))
print -- "$now_epoch $streak" > "$streak_file"

if (( streak < 3 )); then
  exit 0
fi

# Gate 4: cooldown — 5min per trigger (flat; no resolved-marker)
cool_file="${CACHE_DIR}/cooldown-${trigger}"
last_snap_ts=0
[[ -f "$cool_file" ]] && last_snap_ts=$(<"$cool_file")
if (( now_epoch - last_snap_ts < 300 )); then
  exit 0
fi

# Capture
ts_iso=$(date -u +%Y-%m-%dT%H-%M-%SZ)
out="${SNAP_DIR}/${ts_iso}_${trigger}.md"

{
  print -- "# System snapshot — ${trigger} @ ${value}${extra:+ (${extra})} — ${ts_iso}"
  print --
  print -- "## Trigger"
  print -- "- ${trigger}: ${value}${extra:+ (${extra})}; sustained ≥9s"
  print --
  print -- "## Top 10 by RSS"
  print -- '```'
  ps -axo pid,rss,%mem,%cpu,comm -m 2>/dev/null | head -11
  print -- '```'
  print --
  print -- "## Top 10 by CPU"
  print -- '```'
  ps -axo pid,%cpu,%mem,rss,comm -r 2>/dev/null | head -11
  print -- '```'
  print --
  print -- "## Zombies"
  print -- '```'
  ps -axo state,pid,ppid,comm 2>/dev/null | awk 'NR==1 || $1 ~ /^Z/' || true
  print -- '```'
  print --
  print -- "## Swap"
  print -- '```'
  sysctl vm.swapusage 2>/dev/null || true
  print -- '```'
  print --
  print -- "## Memory pressure"
  print -- '```'
  vm_stat 2>/dev/null | head -20 || true
  print -- '```'
  print --
  print -- "## Disk usage"
  print -- '```'
  df -h / 2>/dev/null
  print -- '```'
  print --
  print -- "## I/O sample (5s)"
  print -- '```'
  iostat -d -c 2 -w 5 disk0 2>/dev/null | tail -5 || true
  print -- '```'
  print --
  print -- "## Heuristics"
  baseline_file="${CACHE_DIR}/baseline-rss.tsv"
  # Collect heuristic lines into an array first, then emit. Avoids subshell-scoped
  # `emitted` flag bug from `... | while read` pipelines under default zsh options.
  heur_lines=()
  if [[ -f "$baseline_file" ]]; then
    # Top 5 RSS commands; flag any whose RSS is ≥4× baseline
    while read cmd rss; do
      base=$(awk -v c="$cmd" '$1==c {print $2}' "$baseline_file" | head -1)
      if [[ -n "$base" && "$base" -gt 0 ]]; then
        ratio=$(( rss / base ))
        if (( ratio >= 4 )); then
          heur_lines+=("- ${cmd} at ${rss} KB RSS is ${ratio}× baseline (${base} KB) — restart candidate")
        fi
      fi
    done < <(ps -axo comm,rss -m 2>/dev/null | awk 'NR>1 {print $1,$2}' | head -5)
  fi
  zomb_count=$(ps -axo state 2>/dev/null | awk '$1 ~ /^Z/' | wc -l | tr -d ' ')
  if (( zomb_count > 0 )); then
    heur_lines+=("- ${zomb_count} zombie processes — see Zombies section")
  fi
  if [[ "$trigger" == "fs" ]] && (( ${value%%.*} >= 90 )); then
    heur_lines+=("- FS critical: next scheduled cleanup at 03:00 will reclaim ~20 GB")
  fi
  if [[ "$trigger" == "swap" ]] && (( ${value%%.*} >= 60 )); then
    heur_lines+=("- Swap above 60% — consider restarting top RSS process; see /reclaim")
  fi
  if (( ${#heur_lines[@]} == 0 )); then
    print -- "- (no auto-flagged outliers; review snapshot manually or run /reclaim)"
  else
    for line in "${heur_lines[@]}"; do
      print -- "$line"
    done
  fi
} > "$out"

# Update cooldown
print -- "$now_epoch" > "$cool_file"

# Critical-only notification:
# - fs is critical-only-bound (we only fire fs at critical_action_repeat)
# - mem critical = 92, swap critical = 80, load critical = 1.5
should_notify=0
case "$trigger" in
  fs)   (( ${value%%.*} >= 90 )) && should_notify=1 ;;
  mem)  (( ${value%%.*} >= 92 )) && should_notify=1 ;;
  swap) (( ${value%%.*} >= 80 )) && should_notify=1 ;;
  load) awk -v v="$value" 'BEGIN { exit !(v+0 >= 1.5) }' && should_notify=1 ;;
esac
if (( should_notify )); then
  osascript -e "display notification \"${trigger} at ${value} — snapshot saved\" with title \"DevBox alert\" sound name \"Submarine\"" 2>/dev/null || true
fi
