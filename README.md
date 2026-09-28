# OpenPDS

[![CI](https://github.com/Monotoba/openpds/actions/workflows/ci.yml/badge.svg)](https://github.com/Monotoba/openpds/actions/workflows/ci.yml)
[![Python 3.11+](https://img.shields.io/badge/Python-3.11%2B-blue.svg)](pyproject.toml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

OpenPDS is an offline-first, tool-agnostic product-development standard and
automation toolkit for engineering, manufacturing, verification, business
planning, documentation, and product release.

This repository is an early starter implementation. It includes:

- a Python CLI
- project scaffolding
- validation checks
- release archive generation
- Markdown document building
- JSON schemas
- reusable templates
- unit tests
- GitHub Actions CI
- setup, run, and test scripts using `uv`

## Quick start

Requires Python 3.11 or newer and [uv](https://docs.astral.sh/uv/). The setup
script can install uv if it is missing.

```bash
./setup.sh
./run.sh --help
./test.sh
```

By default, `setup.sh` installs dependencies and runs checks locally. It does
not initialize Git, commit, create a repository, or push. To explicitly create
or push a **private** repository under your authenticated GitHub account, run:

```bash
OPENPDS_SKIP_GITHUB=0 ./setup.sh
```

This publishing option requires the GitHub CLI, authenticated SSH access, and
a clean Git working tree. It preserves an existing `origin` that points to
another repository. Override the target or visibility only when intended:

```bash
OPENPDS_SKIP_GITHUB=0 \
OPENPDS_GITHUB_OWNER=your-account \
OPENPDS_GITHUB_REPO=your-project \
OPENPDS_GITHUB_VISIBILITY=public \
./setup.sh
```

## CLI examples

```bash
./run.sh init-project diode-tester --title "Portable Diode Tester"
./run.sh verify diode-tester
./run.sh build docs
./run.sh release 0.1.2
```

`verify` currently checks the project directory structure, manifest's required
fields, and presence of the requirements CSV. It does not yet validate the
engineering content or certify a product. `build` copies Markdown into the
generated `site/` directory; it refuses to replace an existing directory that
it did not create. `release` creates a documentation and templates ZIP with a
SHA-256 file in `release/`. The Python wheel is built separately by the release
workflow. These are early tools, not a complete product-development standard.

## Design principles

OpenPDS distinguishes exploration, design, and verification. It records
assumptions, evidence, decisions, risks, and completion criteria. It is
intended to work for both people and AI assistants.
