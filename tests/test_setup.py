import os
import subprocess
from pathlib import Path


def test_default_setup_does_not_initialize_or_publish_git(tmp_path: Path) -> None:
    root = Path(__file__).resolve().parents[1]
    script = tmp_path / "setup.sh"
    script.write_bytes((root / "setup.sh").read_bytes())
    fake_bin = tmp_path / "bin"
    fake_bin.mkdir()
    uv = fake_bin / "uv"
    uv.write_text(
        "#!/bin/bash\n"
        "if [[ $1 == sync ]]; then mkdir -p .venv/bin; : > .venv/bin/activate; fi\n",
        encoding="utf-8",
    )
    uv.chmod(0o755)
    for name in ("ruff", "mypy", "pytest"):
        command = fake_bin / name
        command.write_text("#!/bin/sh\nexit 0\n", encoding="utf-8")
        command.chmod(0o755)

    env = os.environ.copy()
    env["PATH"] = f"{fake_bin}:{env['PATH']}"
    env.pop("OPENPDS_SKIP_GITHUB", None)
    result = subprocess.run(["bash", str(script)], env=env, capture_output=True, text=True)

    assert result.returncode == 0, result.stderr
    assert not (tmp_path / ".git").exists()
    assert "Local setup complete" in result.stdout
