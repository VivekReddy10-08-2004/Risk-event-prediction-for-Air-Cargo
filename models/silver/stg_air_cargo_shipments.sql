WITH base AS (
  SELECT *
  FROM {{ ref('br_air_cargo_raw') }}
),
cleaned AS (
  SELECT
    lower(trim(category::VARCHAR)) AS category,
    coalesce(nullif(lower(trim(dest_zone::VARCHAR)), ''), 'missing') AS dest_zone,
    coalesce(nullif(lower(trim(pack_type::VARCHAR)), ''), 'unknown') AS pack_type,
    coalesce(nullif(lower(trim(handling::VARCHAR)), ''), 'unknown') AS handling,
    coalesce(nullif(lower(trim(weather::VARCHAR)), ''), 'unknown') AS weather,
    coalesce(nullif(lower(trim(customs::VARCHAR)), ''), 'unknown') AS customs,
    coalesce(try_cast(distance_km AS DOUBLE), 0) AS distance_km,
    coalesce(try_cast(weight_kg AS DOUBLE), 0) AS weight_kg,
    coalesce(try_cast(volume_m3 AS DOUBLE), 0) AS volume_m3,
    coalesce(try_cast(profit_usd AS DOUBLE), 0) AS profit_usd,
    CASE WHEN try_cast(risk_event AS INTEGER) = 1 THEN 1 ELSE 0 END AS risk_event
  FROM base
)
SELECT
  *,
  CASE WHEN distance_km > 0 AND weight_kg > 0 AND volume_m3 > 0 THEN true ELSE false END AS is_valid_record,
  CASE WHEN profit_usd >= 0 THEN true ELSE false END AS is_profit_valid,
  concat(dest_zone, '|', handling, '|', customs) AS route_key,
  CASE WHEN weather IN ('storm', 'fog', 'snow') THEN 1 ELSE 0 END AS severe_weather_flag,
  CASE WHEN handling = 'hazmat' THEN 1 ELSE 0 END AS hazmat_handling_flag
FROM cleaned
