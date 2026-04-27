#!/bin/zsh
# devbox-worktree-audit.sh
# Args: $1 = repo root (required)
# Stdout: Markdown metadata cards for worktrees that are:
#   - NOT the repo root
#   - last commit ≥14 days ago
#   - clean (`git status --porcelain` empty)
# Stale worktrees that fail "clean" check are emitted with a "uncommitted changes" recommendation
# (still surfaced, never auto-deleted).

set -u
set -o pipefail

REPO="${1:-}"
if [[ -z "$REPO" ]]; then
  print -u2 -- "usage: $0 <repo-root>"
  exit 2
fi
THRESHOLD_DAYS=14
now_epoch=$(date +%s)
threshold_secs=$((THRESHOLD_DAYS * 86400))

if [[ ! -d "$REPO/.git" && ! -f "$REPO/.git" ]]; then
  print -u2 -- "devbox-worktree-audit: not a git repo: $REPO"
  exit 1
fi

git -C "$REPO" worktree list --porcelain | awk '
  /^worktree / { wt = $2 }
  /^HEAD /     { head = $2 }
  /^branch /   { branch = $2 }
  /^bare/      { bare = 1 }
  /^locked/    { locked = 1 }
  /^prunable/  { prunable = 1 }
  /^$/ {
    if (wt && !bare) print wt "\t" head "\t" branch "\t" (locked?"locked":"") "\t" (prunable?"prunable":"")
    wt=""; head=""; branch=""; bare=0; locked=0; prunable=0
  }
  END {
    if (wt && !bare) print wt "\t" head "\t" branch "\t" (locked?"locked":"") "\t" (prunable?"prunable":"")
  }
' | while IFS=$'\t' read wt head branch locked prunable; do
  [[ "$wt" == "$REPO" ]] && continue
  [[ "$locked" == "locked" ]] && continue

  last_commit_epoch=$(git -C "$wt" log -1 --format=%ct 2>/dev/null || echo 0)
  last_commit_iso=$(git -C "$wt" log -1 --format=%cI 2>/dev/null || echo "unknown")
  last_commit_msg=$(git -C "$wt" log -1 --format=%s 2>/dev/null | head -c 80)
  age_days=$(( (now_epoch - last_commit_epoch) / 86400 ))

  (( age_days < THRESHOLD_DAYS )) && continue

  size_h=$(/usr/bin/du -sh "$wt" 2>/dev/null | awk '{print $1}')
  cd "$wt" 2>/dev/null || continue
  status_lines=$(git status --porcelain | wc -l | tr -d ' ')
  cd - >/dev/null

  branch_short="${branch#refs/heads/}"
  upstream_exists="no"
  if [[ -n "$branch_short" ]]; then
    if git -C "$REPO" ls-remote --exit-code origin "$branch_short" >/dev/null 2>&1; then
      upstream_exists="yes"
    fi
  fi

  pr_status="(gh unavailable)"
  if command -v gh >/dev/null 2>&1; then
    if [[ "$upstream_exists" == "yes" ]]; then
      pr_status=$(gh -R "$(git -C "$REPO" config --get remote.origin.url 2>/dev/null)" pr list --head "$branch_short" --state all --json number,state,title --jq '.[0] | "PR #\(.number) \(.state): \(.title)"' 2>/dev/null)
      [[ -z "$pr_status" ]] && pr_status="no PR"
    else
      pr_status="no upstream branch"
    fi
  fi

  recommendation="REVIEW"
  if (( status_lines > 0 )); then
    recommendation="SKIP — uncommitted changes ($status_lines files)"
  elif [[ "$prunable" == "prunable" ]]; then
    recommendation="SAFE — git already flagged as prunable"
  elif [[ "$upstream_exists" == "yes" ]]; then
    recommendation="SAFE — clean + upstream exists"
  else
    recommendation="CAUTION — no upstream branch; data only here"
  fi

  cat <<CARD
- branch:        \`${branch_short:-DETACHED}\`
  path:          \`${wt}\`
  size:          ${size_h}
  last_commit:   ${last_commit_iso} (${age_days}d ago) — "${last_commit_msg}"
  upstream:      ${upstream_exists}
  PR:            ${pr_status}
  uncommitted:   ${status_lines} files
  recommendation: ${recommendation}

CARD
done
