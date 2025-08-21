with source as (
    select
        building_id,
        meter,
        site_id,
        primary_use,
        square_feet,
        year_built,
        floor_count,
        air_temperature,
        cloud_coverage,
        dew_temperature,
        sea_level_pressure,
        wind_direction,
        wind_speed,
        hour,
        day,
        month,
        day_of_week,
        is_weekend,
        meter_reading
    from {{ ref('silver_train') }}
    where
        building_id is not null and
        meter is not null and
        site_id is not null and
        primary_use is not null and
        square_feet is not null and
        year_built is not null and
        floor_count is not null and
        air_temperature is not null and
        cloud_coverage is not null and
        dew_temperature is not null and
        sea_level_pressure is not null and
        wind_direction is not null and
        wind_speed is not null and
        hour is not null and
        day is not null and
        month is not null and
        day_of_week is not null and
        is_weekend is not null and
        meter_reading is not null
)

select * from source