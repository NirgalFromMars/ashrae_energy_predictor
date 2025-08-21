with train as (
    select * from {{ ref('bronze_train') }}
),
weather as (
    select * from {{ ref('bronze_weather_train') }}
),
buildings as (
    select * from {{ ref('bronze_building_metadata') }}
)

select
    t.building_id,
    t.meter,
    t.timestamp,
	extract(hour from t.timestamp) as hour,
    extract(day from t.timestamp) as day,
    extract(month from t.timestamp) as month,
    extract(dayofweek from t.timestamp) as day_of_week,
    case when extract(dayofweek from t.timestamp) in (0,6) then 1 else 0 end as is_weekend,
    t.meter_reading,
    
    b.site_id,
    b.primary_use,
    b.square_feet,
    b.year_built,
    b.floor_count,
    
    w.air_temperature,
    w.cloud_coverage,
    w.dew_temperature,
    w.precip_depth_1_hr,
    w.sea_level_pressure,
    w.wind_direction,
    w.wind_speed

from train t
left join buildings b
    on t.building_id = b.building_id
left join weather w
    on b.site_id = w.site_id and t.timestamp = w.timestamp