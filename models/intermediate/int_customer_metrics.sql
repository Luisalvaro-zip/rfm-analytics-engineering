-- Forzamos a que dbt cree una tabla real en BigQuery (soluciona el no-op)
{{ config(materialized='table') }}

with staging_transactions as (
    select * from {{ ref('stg_retail_transaction') }}
),

-- 1. Calculamos la fecha máxima (el "hoy" del dataset) una sola vez
global_metrics as (
    select max(transaction_date) as max_date 
    from staging_transactions
),

-- 2. Armamos la base del RFM cruzando los datos
rfm_base as (
    select 
        t.customer_id,
        date_diff(cast(max(g.max_date) as date), cast(max(t.transaction_date) as date), DAY) as recency_days,
        count(distinct t.transaction_id) as frequency_count,
        sum(t.quantity * t.unit_price) as monetary_value
    from staging_transactions t
    cross join global_metrics g
    where t.customer_id is not null 
      and trim(cast(t.customer_id as string)) != ''  -- NUEVA REGLA: Filtra espacios en blanco o vacíos
      and cast(t.customer_id as string) != 'nan'
      and t.quantity > 0       -- NUEVA REGLA: Ignoramos devoluciones
      and t.unit_price > 0     -- NUEVA REGLA: Ignoramos items gratis o errores de precio
    group by t.customer_id
)

select * from rfm_base