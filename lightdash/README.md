# Lightdash Setup For Air Cargo 2.0

## Prerequisites
- Node.js installed
- dbt models built successfully (`dbt run`)

## Steps
1. Install Lightdash CLI:
   - `npm install -g @lightdash/cli`
2. Create a Lightdash project in this repository root:
   - `lightdash init`
3. Start Lightdash:
   - `lightdash start`
4. Add metrics and dimensions from the gold models:
   - `mart_route_risk_profile`
   - `mart_handling_risk_profile`

## Suggested Dashboard Tabs
- High Risk Lanes:
  - Top 20 `route_key` by `route_risk_score`
  - `risk_rate` vs `total_profit_usd`
  - Distribution of `operational_risk_tier`
- Handling Performance:
  - `handling_priority_rank`
  - `risk_rate` by `handling`
  - `risky_shipments` trend by customs category
