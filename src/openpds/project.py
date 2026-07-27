from __future__ import annotations

import json
import re
import shutil
from pathlib import Path
from typing import Any

import yaml

from .models import ValidationIssue

PROJECT_DIRS = (
    "requirements",
    "architecture",
    "engineering/hardware",
    "engineering/firmware",
    "engineering/software",
    "engineering/mechanical",
    "verification",
    "manufacturing",
    "business",
    "documentation",
    "decisions",
    "risks",
    "releases",
)

SLUG_RE = re.compile(r"^[a-z0-9][a-z0-9-]*$")


def init_project(destination: Path, title: str, force: bool = False) -> None:
    if destination.exists() and any(destination.iterdir()) and not force:
        raise FileExistsError(
            f"{destination} is not empty. Pass --force only when replacement is intended."
        )

    destination.mkdir(parents=True, exist_ok=True)
    for directory in PROJECT_DIRS:
        (destination / directory).mkdir(parents=True, exist_ok=True)

    slug = destination.name
    if not SLUG_RE.match(slug):
        raise ValueError("Project directory name must use lowercase letters, numbers, and hyphens.")

    manifest = {
        "openpds": {
            "standard_version": "0.1.0",
            "project_id": slug,
            "title": title,
            "lifecycle_phase": "concept",
            "evidence_classes": ["V", "M", "Q", "C", "E", "A", "H", "U"],
            "required_modules": [
                "core",
                "engineering",
                "verification",
                "manufacturing",
                "business",
                "documentation",
            ],
        }
    }
    (destination / "openpds.yaml").write_text(
        yaml.safe_dump(manifest, sort_keys=False), encoding="utf-8"
    )
    (destination / "README.md").write_text(
        f"# {title}\n\nOpenPDS project: `{slug}`.\n", encoding="utf-8"
    )
    (destination / "requirements" / "requirements.csv").write_text(
        "id,title,statement,rationale,source,evidence_class,status,verification_method\n",
        encoding="utf-8",
    )
    (destination / "decisions" / "EDR-000-template.md").write_text(
        decision_template(), encoding="utf-8"
    )
    (destination / "risks" / "risk-register.csv").write_text(
        "id,description,likelihood,impact,mitigation,owner,status\n", encoding="utf-8"
    )


def decision_template() -> str:
    return """# EDR-000: Decision title

## Status
Proposed

## Problem

## Requirements and constraints

## Alternatives considered

## Tradeoffs

## Decision

## Evidence
- Class: U
- Sources:

## Risks

## Review triggers

## Consequences
"""


def verify_project(project_dir: Path) -> list[ValidationIssue]:
    issues: list[ValidationIssue] = []
    manifest_path = project_dir / "openpds.yaml"

    if not manifest_path.exists():
        return [ValidationIssue(str(manifest_path), "Missing OpenPDS project manifest.")]

    try:
        data: Any = yaml.safe_load(manifest_path.read_text(encoding="utf-8"))
    except yaml.YAMLError as exc:
        return [ValidationIssue(str(manifest_path), f"Invalid YAML: {exc}")]

    if not isinstance(data, dict) or not isinstance(data.get("openpds"), dict):
        issues.append(ValidationIssue(str(manifest_path), "Missing top-level 'openpds' mapping."))
        return issues

    openpds = data["openpds"]
    for key in ("standard_version", "project_id", "title", "lifecycle_phase"):
        if not openpds.get(key):
            issues.append(ValidationIssue(str(manifest_path), f"Missing required field: {key}"))

    for directory in PROJECT_DIRS:
        path = project_dir / directory
        if not path.is_dir():
            issues.append(ValidationIssue(str(path), "Missing required project directory."))

    req_path = project_dir / "requirements" / "requirements.csv"
    if not req_path.exists():
        issues.append(ValidationIssue(str(req_path), "Missing requirements traceability file."))

    return issues


def copy_tree(source: Path, destination: Path) -> None:
    if destination.exists():
        shutil.rmtree(destination)
    shutil.copytree(source, destination)


def write_manifest(directory: Path, output: Path) -> None:
    records: list[dict[str, object]] = []
    for path in sorted(p for p in directory.rglob("*") if p.is_file()):
        records.append(
            {
                "path": str(path.relative_to(directory)),
                "size_bytes": path.stat().st_size,
            }
        )
    output.write_text(json.dumps(records, indent=2) + "\n", encoding="utf-8")
