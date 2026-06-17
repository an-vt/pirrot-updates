#!/usr/bin/env bash
set -euo pipefail

UPDATES_REPO="${UPDATES_REPO:-an-vt/pirrot-updates}"

red()   { printf '\033[31m%s\033[0m\n' "$*"; }
green() { printf '\033[32m%s\033[0m\n' "$*"; }
blue()  { printf '\033[34m%s\033[0m\n' "$*"; }

failures=0

check() {
    local label="$1"
    shift

    blue "Checking: $label"
    if "$@" &>/tmp/pirrot-updates-connection-check.log; then
        green "OK: $label"
    else
        red "FAILED: $label"
        sed 's/^/  /' /tmp/pirrot-updates-connection-check.log
        failures=$((failures + 1))
    fi
}

check "gh authentication" gh auth status
check "gh repo access ($UPDATES_REPO)" gh repo view "$UPDATES_REPO"
check "gh push permission ($UPDATES_REPO)" bash -c '
    permission="$(gh api "repos/'"$UPDATES_REPO"'" --jq ".permissions.push")"
    if [[ "$permission" == "true" ]]; then
        exit 0
    fi
    echo "push permission is: ${permission:-missing}"
    exit 1
'
check "git origin remote reachability" git ls-remote origin

if [[ $failures -eq 0 ]]; then
    green "GitHub connection check passed."
    exit 0
fi

red "GitHub connection check failed with $failures issue(s)."
exit 1
