-- Este test fallará si encuentra clientes con gastos negativos o cero compras
with fct_rfm as (
    select * from `ga4-project-496021`.`ga4_data_marts`.`fct_rfm_analysis`
)

select 
    customer_id,
    monetary_value,
    frequency_count
from fct_rfm
where monetary_value < 0 
   or frequency_count <= 0