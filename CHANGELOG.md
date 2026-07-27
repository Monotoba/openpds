# Changelog

All notable changes to OpenPDS will be documented here.

## [Unreleased]

## [0.1.2] - 2026-07-27

### Fixed
- Added `types-PyYAML` to development dependencies so strict mypy checks pass.


## [0.1.1] - 2026-07-27

### Fixed
- Replaced Typer default calls with `typing.Annotated` metadata to satisfy Ruff B008.
- Added `scripts/setup.sh`, `scripts/run.sh`, and `scripts/test.sh` wrappers.


## [0.1.0] - 2026-07-27

### Added
- Initial Python CLI
- Project scaffolding and verification
- Release archive generation
- Core templates and schemas
- GitHub Actions CI and release workflows
