from __future__ import annotations

from pathlib import Path
from typing import Annotated

import typer
from rich.console import Console
from rich.table import Table

from .build import build_docs
from .project import init_project, verify_project
from .release import create_release

app = typer.Typer(
    help="OpenPDS product-development standard and automation toolkit.",
    no_args_is_help=True,
)
console = Console()


@app.command("init-project")
def init_project_command(
    destination: Annotated[Path, typer.Argument(help="New project directory.")],
    title: Annotated[
        str,
        typer.Option("--title", "-t", help="Human-readable product title."),
    ],
    force: Annotated[
        bool,
        typer.Option(help="Allow use of a non-empty destination."),
    ] = False,
) -> None:
    """Create an OpenPDS-compliant project skeleton."""
    try:
        init_project(destination, title, force=force)
    except (FileExistsError, ValueError) as exc:
        console.print(f"[red]Error:[/red] {exc}")
        raise typer.Exit(2) from exc
    console.print(f"[green]Created[/green] {destination}")


@app.command()
def verify(
    project_dir: Annotated[
        Path,
        typer.Argument(exists=True, file_okay=False),
    ] = Path("."),
) -> None:
    """Validate the structure and manifest of an OpenPDS project."""
    issues = verify_project(project_dir)
    if not issues:
        console.print("[green]Verification passed.[/green]")
        return

    table = Table("Severity", "Path", "Message")
    for issue in issues:
        table.add_row(issue.severity, issue.path, issue.message)
    console.print(table)
    raise typer.Exit(1)


@app.command()
def build(
    source: Annotated[
        Path,
        typer.Argument(exists=True, file_okay=False),
    ] = Path("docs"),
    output: Annotated[
        Path,
        typer.Option("--output", "-o"),
    ] = Path("site"),
) -> None:
    """Build documentation into a deterministic output directory."""
    count = build_docs(source, output)
    console.print(f"[green]Built[/green] {count} Markdown files into {output}")


@app.command()
def release(
    version: Annotated[str, typer.Argument(help="Semantic release version.")],
) -> None:
    """Create a versioned ZIP release and SHA-256 checksum file."""
    archive = create_release(Path.cwd(), version)
    console.print(f"[green]Created release:[/green] {archive}")
