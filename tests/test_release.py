from pathlib import Path
from zipfile import ZipFile

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
