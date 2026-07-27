# Troubleshooting

## `./scripts/setup.sh: No such file or directory`

OpenPDS v0.1.1 includes both root-level and `scripts/` wrappers. Either of these
works:

```bash
./setup.sh
./scripts/setup.sh
```

## Ruff B008 errors in `cli.py`

Version 0.1.1 uses `typing.Annotated` for Typer parameters, which avoids Ruff's
B008 warning without disabling the check.


## mypy reports `Library stubs not installed for "yaml"`

Version 0.1.2 includes `types-PyYAML` in the development dependencies. Run:

```bash
uv sync --extra dev
./test.sh
```

For an existing v0.1.1 checkout, this one command is sufficient:

```bash
uv add --dev types-PyYAML
```
