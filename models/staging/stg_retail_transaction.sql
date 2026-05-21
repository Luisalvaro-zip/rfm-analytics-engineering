with sources as (
    select
    * FROM {{ source('kaggle_retail', 'retail_online_raw') }}
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
from transaction_id