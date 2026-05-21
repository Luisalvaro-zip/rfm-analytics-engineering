__dbt__cte__int_customer_metrics as (
with staging_transaction as (
    select *
    from `ga4-project-496021`.`ga4_data_staging`.`stg_retail_transaction`
),

rfm_base as (
    select
        customer_id,
        data_diff((select max(transaction_date) from staging_transaction)), max(transaction_date), DAY) as recency_day,
        count(distict transaction_id) as frecuency_count,
        sum(quantity * unit_price) as monetary value
    from staging_transaction
    where customer_id is not null
    group by customer_id
)

    select * 
    from rfm_base
)