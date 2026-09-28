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

    source_path = source.resolve()
    output_path = output.resolve()
    if (
        source_path == output_path
        or source_path in output_path.parents
        or output_path in source_path.parents
    ):
        raise ValueError("Documentation source and output directories must not overlap.")

    marker = output / ".openpds-build"
    if output.exists() and not marker.is_file():
        raise FileExistsError(f"{output} already exists and is not an OpenPDS build directory.")

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
    marker.write_text("OpenPDS generated documentation\n", encoding="utf-8")
    return count
