# OpenPDS

OpenPDS is an offline-first, tool-agnostic product-development standard and
automation toolkit for engineering, manufacturing, verification, business
planning, documentation, and product release.

This repository is a starter implementation. It includes:

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

```bash
chmod +x setup.sh run.sh test.sh
./setup.sh
./run.sh --help
./test.sh
```

By default, `setup.sh` creates a **private** GitHub repository named
`openpds` under the account `Monotoba`, if the GitHub CLI is installed and
authenticated.

Override defaults as needed:

```bash
OPENPDS_GITHUB_OWNER=Monotoba \
OPENPDS_GITHUB_REPO=openpds \
OPENPDS_GITHUB_VISIBILITY=public \
./setup.sh
```

To skip GitHub setup:

```bash
OPENPDS_SKIP_GITHUB=1 ./setup.sh
```

## CLI examples

```bash
./run.sh init-project diode-tester --title "Portable Diode Tester"
./run.sh verify examples/diode-tester
./run.sh build docs
./run.sh release 0.1.0
```

## Design principles

OpenPDS distinguishes exploration, design, and verification. It records
assumptions, evidence, decisions, risks, and completion criteria. It is
intended to work for both people and AI assistants.
