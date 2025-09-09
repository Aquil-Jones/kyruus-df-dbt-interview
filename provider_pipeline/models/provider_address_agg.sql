-- models/provider_address_agg.sql
{{
    config(
        materialized='table'
    )
}}
-- create table with all possibilities
WITH provider_address_joined AS (
    SELECT 
        provs.id AS provider_id,
        addr.id AS address_id,
        addr.street,
        addr.rank
    FROM {{ ref('providers') }} provs
    LEFT JOIN {{ ref('provider_addresses') }} p_addr
        ON provs.id = p_addr.provider_id
    LEFT JOIN {{ ref('addresses') }} addr
        ON p_addr.address_id = addr.id
)
-- create struct and aggregate into array
SELECT 
    provider_id,
    COALESCE(
        LIST({
            'address_id': address_id,
            'street': street,
            'rank': rank
        }) FILTER (WHERE address_id IS NOT NULL),
        []
    ) AS addresses
FROM provider_address_joined
GROUP BY provider_id
ORDER BY provider_id

/*
This is a different version that would be compatible with BigQuery
{{
    config(
        materialized='table'
    )
}}
-- create table with all possibilities
WITH provider_address_joined AS (
    SELECT 
        provs.id AS provider_id,
        addr.id AS address_id,
        addr.street,
        addr.rank
    FROM {{ ref('providers') }} provs
    LEFT JOIN {{ ref('provider_addresses') }} p_addr
        ON provs.id = p_addr.provider_id
    LEFT JOIN {{ ref('addresses') }} addr
        ON p_addr.address_id = addr.id
)
-- create struct and aggregate into array
SELECT 
    provider_id,
    IFNULL(
        ARRAY_AGG(
            STRUCT(
                address_id,
                street,
                rank
            )
            IGNORE NULLS
        ),
        []
    ) AS addresses
FROM provider_address_joined
GROUP BY provider_id
*/