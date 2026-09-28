# Changelog

All notable changes to OpenPDS will be documented here.

## [Unreleased]

## [0.1.3a1] - 2026-09-27

### Fixed
- Local setup no longer commits or publishes to GitHub unless explicitly requested.
- Documentation builds refuse to replace directories they did not generate or overlap their source.
- Release versions must be safe semantic versions, and existing non-release directories are preserved.
- Corrected the first-run example and clarified the current scope of structural verification.

### Added
- Regression tests for setup defaults, output directory safety, and release version safety.
- CI checks the Python wheel, documentation ZIP, and SHA-256 file before tagging a release.

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
