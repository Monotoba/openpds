from pathlib import Path

import pytest

from openpds.build import build_docs


def test_build_reuses_only_its_own_output(tmp_path: Path) -> None:
    source = tmp_path / "docs"
    source.mkdir()
    (source / "guide.md").write_text("first", encoding="utf-8")
    output = tmp_path / "site"

    assert build_docs(source, output) == 1
    (source / "guide.md").write_text("second", encoding="utf-8")
    assert build_docs(source, output) == 1
    assert (output / "guide.md").read_text(encoding="utf-8") == "second"


@pytest.mark.parametrize("output_name", ["docs", "docs/generated", "."])
def test_build_rejects_overlapping_paths(tmp_path: Path, output_name: str) -> None:
    source = tmp_path / "docs"
    source.mkdir()
    sentinel = source / "important.md"
    sentinel.write_text("keep", encoding="utf-8")

    with pytest.raises(ValueError, match="must not overlap"):
        build_docs(source, tmp_path / output_name)

    assert sentinel.read_text(encoding="utf-8") == "keep"


def test_build_refuses_unmanaged_output(tmp_path: Path) -> None:
    source = tmp_path / "docs"
    source.mkdir()
    output = tmp_path / "site"
    output.mkdir()
    sentinel = output / "important.md"
    sentinel.write_text("keep", encoding="utf-8")

    with pytest.raises(FileExistsError, match="not an OpenPDS build"):
        build_docs(source, output)

    assert sentinel.read_text(encoding="utf-8") == "keep"
