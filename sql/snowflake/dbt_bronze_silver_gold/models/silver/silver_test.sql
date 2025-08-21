with test as (
    select * from {{ ref('bronze_test') }}
),
building_metadata as (
    select * from {{ ref('bronze_building_metadata') }}
),
weather_test as (
    select * from {{ ref('bronze_weather_test') }}
)

select
    t.row_id,
    t.building_id,
    t.meter,
    t.timestamp,
	extract(hour from t.timestamp) as hour,
    extract(day from t.timestamp) as day,
    extract(month from t.timestamp) as month,
    extract(dayofweek from t.timestamp) as day_of_week,
    case when extract(dayofweek from t.timestamp) in (0,6) then 1 else 0 end as is_weekend,
    bm.site_id,
    bm.primary_use,
    bm.square_feet,
    bm.year_built,
    bm.floor_count,
    wt.air_temperature,
    wt.cloud_coverage,
    wt.dew_temperature,
    wt.precip_depth_1_hr,
    wt.sea_level_pressure,
    wt.wind_direction,
    wt.wind_speed
from test t
left join building_metadata bm
    on t.building_id = bm.building_id
left join weather_test wt
    on bm.site_id = wt.site_id and t.timestamp = wt.timestamp