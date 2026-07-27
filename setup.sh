#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

OWNER="${OPENPDS_GITHUB_OWNER:-Monotoba}"
REPO="${OPENPDS_GITHUB_REPO:-openpds}"
VISIBILITY="${OPENPDS_GITHUB_VISIBILITY:-private}"
SKIP_GITHUB="${OPENPDS_SKIP_GITHUB:-0}"

log() { printf '\033[1;34m[openpds]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[openpds warning]\033[0m %s\n' "$*" >&2; }
die() { printf '\033[1;31m[openpds error]\033[0m %s\n' "$*" >&2; exit 1; }

command -v curl >/dev/null 2>&1 || die "curl is required."

if ! command -v uv >/dev/null 2>&1; then
    log "uv not found; installing it with Astral's official installer."
    curl -LsSf https://astral.sh/uv/install.sh | sh

    # The installer normally uses ~/.local/bin or ~/.cargo/bin.
    export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
fi

command -v uv >/dev/null 2>&1 || die "uv installation completed, but uv is not on PATH."

log "Using $(uv --version)"
log "Creating/updating the virtual environment and installing dependencies."
uv sync --extra dev

# shellcheck disable=SC1091
source "$PROJECT_DIR/.venv/bin/activate"

log "Running project checks."
ruff check .
mypy src
pytest

if [[ ! -d .git ]]; then
    log "Initializing local Git repository."
    git init -b main
fi

git config user.name >/dev/null 2>&1 || \
    warn "Git user.name is unset. Configure it with: git config --global user.name 'Your Name'"
git config user.email >/dev/null 2>&1 || \
    warn "Git user.email is unset. Configure it with: git config --global user.email 'you@example.com'"

git add .
if ! git diff --cached --quiet; then
    log "Creating initial commit."
    git commit -m "Initial OpenPDS project scaffold"
else
    log "No uncommitted project changes to commit."
fi

if [[ "$SKIP_GITHUB" == "1" ]]; then
    log "Skipping GitHub repository setup because OPENPDS_SKIP_GITHUB=1."
    exit 0
fi

if ! command -v gh >/dev/null 2>&1; then
    warn "GitHub CLI (gh) is not installed. Local setup is complete."
    warn "Install gh, run 'gh auth login', then rerun ./setup.sh."
    exit 0
fi

if ! gh auth status >/dev/null 2>&1; then
    warn "GitHub CLI is not authenticated. Local setup is complete."
    warn "Run 'gh auth login' and choose SSH for Git operations, then rerun ./setup.sh."
    exit 0
fi

case "$VISIBILITY" in
    private|public|internal) ;;
    *) die "OPENPDS_GITHUB_VISIBILITY must be private, public, or internal." ;;
esac

if gh repo view "$OWNER/$REPO" >/dev/null 2>&1; then
    log "GitHub repository $OWNER/$REPO already exists."
    if ! git remote get-url origin >/dev/null 2>&1; then
        git remote add origin "git@github.com:$OWNER/$REPO.git"
    fi
else
    log "Creating GitHub repository $OWNER/$REPO with $VISIBILITY visibility."
    gh repo create "$OWNER/$REPO" \
        "--$VISIBILITY" \
        --source=. \
        --remote=origin \
        --description="Open Product Development Standard and automation toolkit"
fi

# Ensure SSH is used, matching the user's requested setup.
git remote set-url origin "git@github.com:$OWNER/$REPO.git"

log "Pushing main branch."
git push -u origin main

log "Setup complete."
log "Repository: https://github.com/$OWNER/$REPO"
