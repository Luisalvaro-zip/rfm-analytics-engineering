
    
    

with all_values as (

    select
        rfm_segment as value_field,
        count(*) as n_records

    from `ga4-project-496021`.`ga4_data_marts`.`fct_rfm_analysis`
    group by rfm_segment

)

select *
from all_values
where value_field not in (
    'Campeones','Clientes Leales','Nuevos Clientes','No Podemos Perderlos','Hibernando / Perdidos','Regulares / Potenciales'
)


