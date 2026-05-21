

  create or replace view `ga4-project-496021`.`ga4_data_staging`.`stg_retail_transaction`
  OPTIONS()
  as with sources as (
    select
    * FROM `ga4-project-496021`.`ga4_data`.`retail_online_raw`
),

    transaction_id as (
    select
    invoice as transaction_id,
    customer_id,
    description as product_name,
    quantity,
    price as unit_price,
    invoicedate as transaction_date
    FROM sources
)

select * 
from transaction_id;

