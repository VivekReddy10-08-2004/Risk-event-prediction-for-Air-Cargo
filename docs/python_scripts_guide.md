# Python Scripts Guide (Simple Explanation)

This document explains every Python script in this project in plain language:
- what the script does (objective)
- why each function exists

## 1) scripts/run_air_cargo_local.py

### Objective
This script is the main pipeline runner.
It runs the full local analytics workflow in one command:
1. check dbt connection/config
2. build models
3. run data tests
4. generate docs
5. export final datasets for Power BI

### Functions and Why They Exist

#### get_dbt_command_prefix()
Purpose:
Find the correct dbt command for the current Python environment.

Why this function is needed:
- On Windows, dbt is often inside the active environment's Scripts folder.
- On Linux/macOS, it may be in a different location.
- If dbt executable is not found directly, it falls back to python -m dbt.cli.main.

In simple terms:
It prevents "wrong Python/wrong dbt" issues and makes the script more reliable across environments.

#### run_step(step_name, command, cwd)
Purpose:
Run one pipeline step and fail fast if that step fails.

Why this function is needed:
- Keeps repeated subprocess logic in one place.
- Shows clear progress in terminal (which step is running).
- Stops immediately when a step fails, so bad output is not propagated.

In simple terms:
It is a safety wrapper that runs each stage cleanly and gives clear errors.

#### main()
Purpose:
Coordinate the full pipeline.

What it does:
- Detects project root and dbt profile path.
- Builds the ordered dbt steps (debug, run, test, docs).
- Runs all steps one by one.
- Runs export_powerbi_data.py at the end.
- Prints final success/help messages.

Why this function is needed:
It is the single orchestration point so users only run one command.

In simple terms:
This is the "master control" function for local ELT + export.

---

## 2) scripts/export_powerbi_data.py

### Objective
This script exports final Gold layer tables from DuckDB into CSV files for Power BI.

### Functions and Why They Exist

#### main()
Purpose:
Connect to DuckDB, export selected marts, then close the connection.

What it does:
- Finds project root and DuckDB path.
- Creates bi_exports folder if it does not exist.
- Opens DuckDB in read-only mode.
- Defines which SQL query maps to which CSV file.
- Executes COPY statements to write CSV files.
- Prints each exported file path.
- Closes the database connection.

Why this function is needed:
- Gives a stable, repeatable export process for BI refresh.
- Read-only connection reduces risk of accidental writes.
- CSV export avoids Power BI ODBC lock issues on local DuckDB files.

In simple terms:
It turns trusted Gold tables into easy-to-load Power BI files.

---

## Expected Output Files
After running the full pipeline, these files should be updated:
- bi_exports/mart_route_risk_profile.csv
- bi_exports/mart_handling_risk_profile.csv

## Recommended Run Command
Use the same Python environment where dbt is installed:

```bash
python scripts/run_air_cargo_local.py
```

If you use Anaconda in this project, run with that Python executable.
