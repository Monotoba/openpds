from __future__ import annotations

import hashlib
import json
import re
import shutil
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile

from .project import write_manifest

VERSION_RE = re.compile(
    r"^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)"
    r"(?:-[0-9A-Za-z]+(?:[.-][0-9A-Za-z]+)*)?$"
)


def _sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def create_release(repository: Path, version: str) -> Path:
    if not VERSION_RE.fullmatch(version):
        raise ValueError("Version must be a semantic version such as 0.1.2 or 0.1.2-alpha.1.")

    release_dir = repository / "release" / f"openpds-{version}"
    if release_dir.exists():
        if not (release_dir / "MANIFEST.json").is_file():
            raise FileExistsError(f"{release_dir} exists but is not a prior OpenPDS release.")
        shutil.rmtree(release_dir)
    release_dir.mkdir(parents=True)

    included = [
        "README.md",
        "LICENSE",
        "CHANGELOG.md",
        "docs",
        "templates",
        "schemas",
        "examples",
        "prompts",
    ]

    for item in included:
        source = repository / item
        if not source.exists():
            continue
        target = release_dir / item
        if source.is_dir():
            shutil.copytree(source, target)
        else:
            shutil.copy2(source, target)

    write_manifest(release_dir, release_dir / "MANIFEST.json")

    archive = repository / "release" / f"openpds-{version}.zip"
    with ZipFile(archive, "w", ZIP_DEFLATED) as bundle:
        for path in sorted(p for p in release_dir.rglob("*") if p.is_file()):
            bundle.write(path, path.relative_to(release_dir.parent))

    checksums = {
        archive.name: _sha256(archive),
    }
    (repository / "release" / f"openpds-{version}-SHA256.json").write_text(
        json.dumps(checksums, indent=2) + "\n", encoding="utf-8"
    )
    return archive
