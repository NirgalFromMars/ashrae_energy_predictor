with source as (
    select
        site_id,
        primary_use,
        meter,
        extract(hour from timestamp) as hour,
        meter_reading
    from {{ ref('silver_train') }}
)

select
    site_id,
    primary_use,
    meter,
    hour,
    avg(meter_reading) as avg_meter_reading
from source
group by site_id, primary_use, meter, hour
order by site_id, primary_use, meter, hour