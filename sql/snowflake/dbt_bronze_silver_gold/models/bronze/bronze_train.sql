WITH source AS (
    SELECT
        CAST(building_id AS INTEGER) AS building_id,
        CAST(meter AS INTEGER) AS meter,
        CAST(timestamp AS TIMESTAMP) AS timestamp,
        CAST(meter_reading AS FLOAT64) AS meter_reading
    FROM {{ source('raw', 'train') }}
)

SELECT *
FROM source