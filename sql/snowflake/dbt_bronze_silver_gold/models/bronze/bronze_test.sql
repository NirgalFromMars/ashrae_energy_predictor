SELECT
    row_id,
    building_id,
    meter,
    timestamp
FROM {{ source('raw', 'test') }}