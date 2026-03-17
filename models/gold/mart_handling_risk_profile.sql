WITH base AS (
  SELECT *
  FROM {{ ref('stg_air_cargo_shipments') }}
  WHERE is_valid_record = true
),
rollup AS (
  SELECT
    handling,
    customs,
    count(*) AS shipment_count,
    sum(risk_event) AS risky_shipments,
    avg(risk_event) AS risk_rate,
    avg(profit_usd) AS avg_profit_usd,
    sum(profit_usd) AS total_profit_usd,
    avg(severe_weather_flag) AS severe_weather_share
  FROM base
  GROUP BY 1,2
)
SELECT
  *,
  dense_rank() OVER (ORDER BY risk_rate DESC, shipment_count DESC) AS handling_priority_rank
FROM rollup
ORDER BY handling_priority_rank
