
-- This is another verion for duckdb that has tie-breaking it was unneccessary with
--  the sample data but in full production data there could be ties
{{
    config(
        materialized='table'
    )
}}

WITH providers_degrees_split AS (
    SELECT 
        p.id AS provider_id,
        TRIM(unnest(string_split(p.degrees, ','))) AS degree
    FROM {{ ref('providers') }} p
    WHERE p.degrees IS NOT NULL AND p.degrees != ''
),

providers_with_ranks AS (
    SELECT 
        pds.provider_id,
        dt.ptui,
        dt.rank,
        dt.degree  -- Keep degree for tie-breaking
    FROM providers_degrees_split pds
    INNER JOIN {{ ref('degrees_types') }} dt
        ON pds.degree = dt.degree
),

providers_lowest_rank AS (
    SELECT 
        provider_id,
        ptui,
        rank,
        -- Deterministic: First by rank (ascending), then by degree name (alphabetically)
        -- This ensures consistent results even when ranks are tied
        ROW_NUMBER() OVER (
            PARTITION BY provider_id 
            ORDER BY rank ASC, degree ASC
        ) AS rn
    FROM providers_with_ranks
)

SELECT 
    p.id AS provider_id,
    plr.ptui
FROM {{ ref('providers') }} p
LEFT JOIN providers_lowest_rank plr
    ON p.id = plr.provider_id AND plr.rn = 1
ORDER BY provider_id
