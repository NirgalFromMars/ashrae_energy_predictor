with agg as (
    select
        building_id,
        count(*) as num_records,
        avg(meter_reading) as avg_meter_reading,
        max(meter_reading) as max_meter_reading,
        min(meter_reading) as min_meter_reading,
        stddev(meter_reading) as stddev_meter_reading
    from {{ ref('silver_train') }}
    group by building_id
),

attributes as (
    select
        building_id,
        primary_use,
        square_feet,
        year_built,
        floor_count
    from {{ ref('silver_train') }}
    qualify row_number() over (partition by building_id order by timestamp) = 1
)

select
    a.building_id,
    a.num_records,
    a.avg_meter_reading,
    a.max_meter_reading,
    a.min_meter_reading,
    a.stddev_meter_reading,
    attr.primary_use,
    attr.square_feet,
    attr.year_built,
    attr.floor_count
from agg a
left join attributes attr on a.building_id = attr.building_id