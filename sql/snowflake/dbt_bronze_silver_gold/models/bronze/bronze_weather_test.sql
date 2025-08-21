SELECT
    site_id,
    timestamp,
    air_temperature,
    cloud_coverage,
    dew_temperature,
    precip_depth_1_hr,
    sea_level_pressure,
    wind_direction,
    wind_speed
FROM {{ source('raw', 'weather_test') }}