"""Run the local Air Cargo analytics pipeline end-to-end.

This script orchestrates dbt validation/build/test/docs steps and then exports
Power BI-ready CSV outputs from the gold marts.
"""

import subprocess
import sys
from pathlib import Path


def get_dbt_command_prefix() -> list[str]:
    """Return the best dbt command for the active Python environment.

    Priority:
    1) Local env dbt executable on Windows (Scripts/dbt.exe)
    2) Local env dbt executable on Unix (bin/dbt-like path)
    3) Python module fallback (python -m dbt.cli.main)
    """
    python_path = Path(sys.executable)
    windows_dbt = python_path.parent / "Scripts" / "dbt.exe"
    unix_dbt = python_path.parent / "dbt"

    if windows_dbt.exists():
        return [str(windows_dbt)]

    if unix_dbt.exists():
        return [str(unix_dbt)]

    return [sys.executable, "-m", "dbt.cli.main"]


def run_step(step_name: str, command: list[str], cwd: Path) -> None:
    """Execute one pipeline step and stop immediately on failure."""
    print(f"\n==> {step_name}")
    result = subprocess.run(command, cwd=cwd, check=False)
    if result.returncode != 0:
        raise SystemExit(f"Step failed: {step_name} (exit code {result.returncode})")


def main() -> None:
    """Run dbt workflow, then export final marts for Power BI consumption."""
    repo_root = Path(__file__).resolve().parent.parent
    profiles_dir = str(repo_root / "profiles")
    dbt_command_prefix = get_dbt_command_prefix()

    steps = [
        ("dbt debug", [*dbt_command_prefix, "debug", "--profiles-dir", profiles_dir]),
        ("dbt run", [*dbt_command_prefix, "run", "--profiles-dir", profiles_dir]),
        ("dbt test", [*dbt_command_prefix, "test", "--profiles-dir", profiles_dir]),
        (
            "dbt docs generate",
            [*dbt_command_prefix, "docs", "generate", "--profiles-dir", profiles_dir],
        ),
    ]

    for step_name, command in steps:
        run_step(step_name, command, repo_root)

    # Export curated gold marts to CSV so Power BI can refresh without ODBC file locks.
    run_step(
        "export Power BI datasets",
        [sys.executable, str(repo_root / "scripts" / "export_powerbi_data.py")],
        repo_root,
    )

    print("\nPipeline completed successfully.")
    print("To view docs: dbt docs serve --profiles-dir profiles")
    print("Power BI files: bi_exports/mart_route_risk_profile.csv and bi_exports/mart_handling_risk_profile.csv")


if __name__ == "__main__":
    main()