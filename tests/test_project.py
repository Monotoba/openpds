from pathlib import Path

from openpds.project import init_project, verify_project


def test_init_and_verify_project(tmp_path: Path) -> None:
    project = tmp_path / "diode-tester"
    init_project(project, "Portable Diode Tester")
    assert (project / "openpds.yaml").exists()
    assert verify_project(project) == []


def test_missing_manifest_fails(tmp_path: Path) -> None:
    project = tmp_path / "empty-project"
    project.mkdir()
    issues = verify_project(project)
    assert issues
    assert "manifest" in issues[0].message.lower()
