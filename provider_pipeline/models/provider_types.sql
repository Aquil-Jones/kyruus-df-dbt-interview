{{
    config(
        materialized='table'
    )
}}

WITH providers_degrees_split AS (
    -- Split the comma-separated degrees string into individual degrees
    SELECT 
        provs.id AS provider_id,
        TRIM(unnest(string_split(provs.degrees, ','))) AS degree
    FROM {{ ref('providers') }} provs
    WHERE provs.degrees IS NOT NULL AND provs.degrees != ''
    -- not sure what form nulls are here so controlling for two types than can mess up the unnest
),

providers_with_ranks AS (
    -- Join with degrees_types to get ptui and rank for each degree
    SELECT 
        pds.provider_id,
        deg_t.ptui,
        deg_t.rank
    FROM providers_degrees_split pds
    -- Inner join to only keep ranks that exist in degree_types
    INNER JOIN {{ ref('degree_types') }} deg_t
        ON pds.degree = deg_t.degree
),

providers_lowest_rank AS (
    -- Find the ptui with the lowest rank for each provider
    SELECT 
        provider_id,
        ptui,
        rank,
        ROW_NUMBER() OVER (PARTITION BY provider_id ORDER BY rank ASC) AS rn
    FROM providers_with_ranks
)

-- Final select: one row per provider with the ptui of lowest rank
SELECT 
    provs.id AS provider_id,
    plr.ptui
FROM {{ ref('providers') }} provs
LEFT JOIN providers_lowest_rank plr
    ON provs.id = plr.provider_id AND plr.rn = 1
ORDER BY provider_id

/*
This is a different version that would be compatible with BigQuery
{{
    config(
        materialized='table'
    )
}}

WITH providers_degrees_split AS (
    -- Split the comma-separated degrees string into individual degrees
    SELECT 
        provs.id AS provider_id,
        TRIM(degree) AS degree
    FROM {{ ref('providers') }} provs
    -- interesting note about bigquery unnest it consders unnest a table operator  not a set returning function  hence the cross join
    CROSS JOIN UNNEST(SPLIT(provs.degrees, ',')) AS degree
    WHERE provs.degrees IS NOT NULL AND provs.degrees != ''
    -- not sure what form nulls are here so controlling for two types than can mess up the unnest
),

providers_with_ranks AS (
    -- Join with degrees_types to get ptui and rank for each degree
    SELECT 
        pds.provider_id,
        deg_t.ptui,
        deg_t.rank
    FROM providers_degrees_split pds
    -- Inner join to only keep ranks that exist in degree_types
    INNER JOIN {{ ref('degree_types') }} deg_t
        ON pds.degree = deg_t.degree
),

providers_lowest_rank AS (
    -- Find the ptui with the lowest rank for each provider
    SELECT 
        provider_id,
        ptui,
        rank,
        ROW_NUMBER() OVER (PARTITION BY provider_id ORDER BY rank ASC) AS rn
    FROM providers_with_ranks
)

-- Final select: one row per provider with the ptui of lowest rank
SELECT 
    provs.id AS provider_id,
    plr.ptui
FROM {{ ref('providers') }} provs
LEFT JOIN providers_lowest_rank plr
    ON provs.id = plr.provider_id AND plr.rn = 1
ORDER BY provider_id
*/