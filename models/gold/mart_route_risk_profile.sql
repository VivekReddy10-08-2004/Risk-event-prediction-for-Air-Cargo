WITH cleaned AS (
  SELECT *
  FROM {{ ref('stg_air_cargo_shipments') }}
  WHERE is_valid_record = true
    AND is_profit_valid = true
),
thresholds AS (
  SELECT quantile_cont(profit_usd, {{ var('high_value_quantile') }}) AS high_value_profit_cutoff
  FROM cleaned
),
high_value AS (
  SELECT c.*
  FROM cleaned c
  CROSS JOIN thresholds t
  WHERE c.profit_usd >= t.high_value_profit_cutoff
),
route_rollup AS (
  SELECT
    route_key,
    dest_zone,
    handling,
    customs,
    count(*) AS high_value_shipments,
    sum(risk_event) AS risky_shipments,
    avg(risk_event) AS risk_rate,
    avg(profit_usd) AS avg_profit_usd,
    sum(profit_usd) AS total_profit_usd,
    avg(distance_km) AS avg_distance_km,
    avg(weight_kg) AS avg_weight_kg,
    avg(volume_m3) AS avg_volume_m3,
    avg(severe_weather_flag) AS severe_weather_share,
    avg(hazmat_handling_flag) AS hazmat_share
  FROM high_value
  GROUP BY 1,2,3,4
),
scored AS (
  SELECT
    *,
    (
      (risk_rate * {{ var('risk_rate_weight') }})
      + ((severe_weather_share + hazmat_share) * {{ var('disruption_weight') }})
      + (percent_rank() OVER (ORDER BY total_profit_usd DESC) * {{ var('profit_weight') }})
    ) AS route_risk_score
  FROM route_rollup
),
ranked AS (
  SELECT
    *,
    ntile(10) OVER (ORDER BY route_risk_score DESC) AS risk_decile,
    dense_rank() OVER (ORDER BY route_risk_score DESC, total_profit_usd DESC) AS route_priority_rank
  FROM scored
  WHERE high_value_shipments >= {{ var('min_route_shipments') }}
)
SELECT
  route_priority_rank,
  route_key,
  dest_zone,
  handling,
  customs,
  high_value_shipments,
  risky_shipments,
  risk_rate,
  total_profit_usd,
  avg_profit_usd,
  avg_distance_km,
  avg_weight_kg,
  avg_volume_m3,
  severe_weather_share,
  hazmat_share,
  route_risk_score,
  risk_decile,
  CASE
    WHEN risk_decile <= 2 THEN 'critical'
    WHEN risk_decile <= 5 THEN 'high'
    WHEN risk_decile <= 8 THEN 'moderate'
    ELSE 'watch'
  END AS operational_risk_tier
FROM ranked
ORDER BY route_priority_rank
