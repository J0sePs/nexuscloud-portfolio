#!/usr/bin/env bash
# git-as.sh — Switch git identity for simulated team members
# Usage: git-as {a-lead|b-dev|c-sec|d-ops|--show|--reset}

DEFAULT_NAME="${GIT_DEFAULT_NAME:-Your Name}"
DEFAULT_EMAIL="${GIT_DEFAULT_EMAIL:-you@example.com}"

case "$1" in
  a-lead|A-LEAD)
    git config user.name "Alex Rivera"
    git config user.email "a.rivera@nexuscloud.local"
    echo "🎩 [A-LEAD] Now committing as Alex Rivera (Tech Lead)"
    ;;
  b-dev|B-DEV)
    git config user.name "Bruno Torres"
    git config user.email "b.torres@nexuscloud.local"
    echo "💻 [B-DEV] Now committing as Bruno Torres (Backend Developer)"
    ;;
  c-sec|C-SEC)
    git config user.name "Carla Chen"
    git config user.email "c.chen@nexuscloud.local"
    echo "🔒 [C-SEC] Now committing as Carla Chen (Security & DevSecOps)"
    ;;
  d-ops|D-OPS)
    git config user.name "Daniela Reyes"
    git config user.email "d.reyes@nexuscloud.local"
    echo "🚨 [D-OPS] Now committing as Daniela Reyes (SRE)"
    ;;
  --show|-s)
    echo "Current: $(git config user.name) <$(git config user.email)>"
    ;;
  --reset|-r)
    git config user.name "$DEFAULT_NAME"
    git config user.email "$DEFAULT_EMAIL"
    echo "↩️  Reset to default"
    ;;
  *)
    cat <<HELP
Usage: git-as {a-lead|b-dev|c-sec|d-ops|--show|--reset}

Team members:
  a-lead   Alex Rivera    Tech Lead / Platform Engineer
  b-dev    Bruno Torres   Backend Developer
  c-sec    Carla Chen     Security & DevSecOps Engineer
  d-ops    Daniela Reyes  Site Reliability Engineer

Current: $(git config user.name) <$(git config user.email)>
HELP
    exit 1
    ;;
esac
