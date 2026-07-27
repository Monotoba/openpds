from __future__ import annotations

import shutil
from pathlib import Path


def build_docs(source: Path, output: Path) -> int:
    """Copy Markdown documentation into a deterministic build directory.

    This initial builder intentionally avoids requiring Pandoc. Future versions
    can add optional PDF, DOCX, and static-site backends.
    """
    if not source.is_dir():
        raise NotADirectoryError(source)

    if output.exists():
        shutil.rmtree(output)
    output.mkdir(parents=True)

    count = 0
    for path in source.rglob("*.md"):
        relative = path.relative_to(source)
        target = output / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(path, target)
        count += 1
    return count
