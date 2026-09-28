from pathlib import Path
from zipfile import ZipFile

import pytest

from openpds.release import create_release


def test_create_release(tmp_path: Path) -> None:
    (tmp_path / "README.md").write_text("# Test\n", encoding="utf-8")
    (tmp_path / "LICENSE").write_text("Test\n", encoding="utf-8")
    (tmp_path / "docs").mkdir()
    (tmp_path / "docs" / "index.md").write_text("# Docs\n", encoding="utf-8")

    archive = create_release(tmp_path, "0.1.0")
    assert archive.exists()

    with ZipFile(archive) as bundle:
        names = bundle.namelist()
    assert any(name.endswith("MANIFEST.json") for name in names)


@pytest.mark.parametrize("version", ["../outside", "0.1.2/../../outside", "not-a-version"])
def test_invalid_version_does_not_touch_other_files(tmp_path: Path, version: str) -> None:
    sentinel = tmp_path / "outside"
    sentinel.mkdir()
    (sentinel / "important.txt").write_text("keep", encoding="utf-8")

    with pytest.raises(ValueError, match="release version"):
        create_release(tmp_path, version)

    assert (sentinel / "important.txt").read_text(encoding="utf-8") == "keep"


def test_release_refuses_to_replace_unmanaged_directory(tmp_path: Path) -> None:
    target = tmp_path / "release" / "openpds-0.1.2"
    target.mkdir(parents=True)
    (target / "important.txt").write_text("keep", encoding="utf-8")

    with pytest.raises(FileExistsError, match="prior OpenPDS release"):
        create_release(tmp_path, "0.1.2")

    assert (target / "important.txt").read_text(encoding="utf-8") == "keep"


def test_release_can_rebuild_its_own_directory(tmp_path: Path) -> None:
    (tmp_path / "README.md").write_text("# Test\n", encoding="utf-8")
    first = create_release(tmp_path, "0.1.3a1")
    second = create_release(tmp_path, "0.1.3a1")
    assert first == second
    with ZipFile(second) as bundle:
        assert bundle.testzip() is None
