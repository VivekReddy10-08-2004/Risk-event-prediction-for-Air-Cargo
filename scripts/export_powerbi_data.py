"""Export gold dbt marts from DuckDB into CSV files for Power BI.

The exports are intentionally produced from a read-only DuckDB connection to
avoid accidental writes and to keep BI refresh inputs stable.
"""

from pathlib import Path

import duckdb


def main() -> None:
    """Write route and handling risk marts to the bi_exports directory."""
    repo_root = Path(__file__).resolve().parent.parent
    db_path = repo_root / "air_cargo_ops.duckdb"
    export_dir = repo_root / "bi_exports"
    export_dir.mkdir(exist_ok=True)

    # Read-only mode protects the warehouse file during export.
    con = duckdb.connect(str(db_path), read_only=True)

    exports = {
        "mart_route_risk_profile.csv": "SELECT * FROM analytics_gold.mart_route_risk_profile ORDER BY route_priority_rank",
        "mart_handling_risk_profile.csv": "SELECT * FROM analytics_gold.mart_handling_risk_profile ORDER BY handling_priority_rank",
    }

    for file_name, query in exports.items():
        output_path = export_dir / file_name
        escaped_path = str(output_path).replace("'", "''")
        # COPY is used for fast, reproducible CSV exports with headers.
        con.execute(f"COPY ({query}) TO '{escaped_path}' WITH (HEADER, DELIMITER ',')")
        print(f"Exported: {output_path}")

    con.close()


if __name__ == "__main__":
    main()
