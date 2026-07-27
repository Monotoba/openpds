#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

command -v uv >/dev/null 2>&1 || {
    echo "uv is required." >&2
    exit 1
}

uv add --dev 'types-PyYAML>=6.0.12,<7'
uv sync --extra dev

if [[ -d .venv ]]; then
    # shellcheck disable=SC1091
    source .venv/bin/activate
fi

ruff check .
mypy src
pytest
