SELECT
  category,
  dest_zone,
  pack_type,
  handling,
  weather,
  customs,
  distance_km,
  weight_kg,
  volume_m3,
  profit_usd,
  risk_event
FROM read_csv_auto('{{ var("raw_csv_path") }}', header = true)
