SELECT
    site_id,
    building_id,
    primary_use,
    square_feet,
    year_built,
    floor_count
FROM {{ source('raw', 'building_metadata') }}