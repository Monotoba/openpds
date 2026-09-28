#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

OWNER="${OPENPDS_GITHUB_OWNER:-}"
REPO="${OPENPDS_GITHUB_REPO:-$(basename "$PROJECT_DIR")}"
VISIBILITY="${OPENPDS_GITHUB_VISIBILITY:-private}"
SKIP_GITHUB="${OPENPDS_SKIP_GITHUB:-1}"

log() { printf '\033[1;34m[openpds]\033[0m %s\n' "$*"; }
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

if [[ "$SKIP_GITHUB" == "1" ]]; then
    log "Local setup complete. To create and push a GitHub repository, explicitly set OPENPDS_SKIP_GITHUB=0."
    exit 0
fi
[[ "$SKIP_GITHUB" == "0" ]] || die "OPENPDS_SKIP_GITHUB must be 0 or 1."

if ! command -v gh >/dev/null 2>&1; then
    die "GitHub CLI (gh) is required for the requested publish step."
fi

if ! gh auth status >/dev/null 2>&1; then
    die "GitHub CLI is not authenticated. Run 'gh auth login' before publishing."
fi

if [[ -z "$OWNER" ]]; then
    OWNER="$(gh api user --jq .login)" || die "Could not determine the authenticated GitHub account."
fi
[[ -n "$OWNER" ]] || die "Set OPENPDS_GITHUB_OWNER to your GitHub account."

case "$VISIBILITY" in
    private|public|internal) ;;
    *) die "OPENPDS_GITHUB_VISIBILITY must be private, public, or internal." ;;
esac

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    [[ -z "$(git status --porcelain)" ]] || die "Commit or discard local changes before publishing."
else
    log "Initializing local Git repository."
    git init -b main
    git config user.name >/dev/null 2>&1 || die "Configure git user.name before publishing."
    git config user.email >/dev/null 2>&1 || die "Configure git user.email before publishing."
    git add .
    git commit -m "Initial OpenPDS project scaffold"
fi

if gh repo view "$OWNER/$REPO" >/dev/null 2>&1; then
    log "GitHub repository $OWNER/$REPO already exists."
else
    log "Creating GitHub repository $OWNER/$REPO with $VISIBILITY visibility."
    gh repo create "$OWNER/$REPO" \
        "--$VISIBILITY" \
        --description="Open Product Development Standard and automation toolkit"
fi

TARGET_REMOTE="git@github.com:$OWNER/$REPO.git"
if git remote get-url origin >/dev/null 2>&1; then
    if [[ "$(git remote get-url origin)" == "$TARGET_REMOTE" ]]; then
        PUSH_REMOTE=origin
    else
        # Keep the source repository's origin intact when publishing a fork.
        if git remote get-url openpds-publish >/dev/null 2>&1; then
            [[ "$(git remote get-url openpds-publish)" == "$TARGET_REMOTE" ]] || \
                die "The openpds-publish remote points to another repository."
        else
            git remote add openpds-publish "$TARGET_REMOTE"
        fi
        PUSH_REMOTE=openpds-publish
    fi
else
    git remote add origin "$TARGET_REMOTE"
    PUSH_REMOTE=origin
fi

log "Pushing main branch."
git push -u "$PUSH_REMOTE" main

log "Setup complete."
log "Repository: https://github.com/$OWNER/$REPO"
