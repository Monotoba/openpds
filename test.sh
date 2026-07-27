#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

if [[ ! -d .venv ]]; then
    printf 'Virtual environment not found. Run ./setup.sh first.\n' >&2
    exit 1
fi

# shellcheck disable=SC1091
source "$PROJECT_DIR/.venv/bin/activate"

ruff check .
mypy src
pytest
