# Air Cargo Risk Event Prediction

This project predicts shipment risk events and convert model outputs into operational recommendations.

## Project Goal
Build a classification pipeline that identifies risky cargo events early enough to support preventive action in logistics workflows.

## Notebook
- `Ai_cargo_risk_level.ipynb`: complete analysis, modeling, evaluation, and business insights.

## What This Project Demonstrates
- Data auditing and missing-value strategy
- Categorical encoding and leakage-safe train/test split
- Baseline vs imbalance-aware modeling (SMOTE)
- Metric selection aligned to business cost (recall and false negatives)
- Feature importance interpretation for decision support

## Key Business Value
- Reduces missed high-risk shipments by improving minority-class detection
- Highlights risk drivers tied to cargo profile and operating conditions
- Supports targeted interventions in handling, route planning, and customs flow

## Tech Stack
- Python
- pandas, numpy
- scikit-learn
- imbalanced-learn
- matplotlib
- kagglehub

## Run Locally
1. Create and activate a virtual environment.
2. Install dependencies:

```bash
pip install -r requirements.txt
```

3. Open `Ai_cargo_risk_level.ipynb` and run all cells.

## Suggested Resume Bullet
Designed an end-to-end air cargo risk classification pipeline with imbalance-aware modeling (SMOTE + Random Forest), improving risk-event detection and translating top feature drivers into actionable logistics controls.
