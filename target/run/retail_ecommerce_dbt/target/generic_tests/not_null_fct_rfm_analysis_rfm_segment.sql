
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select rfm_segment
from `ga4-project-496021`.`ga4_data_marts`.`fct_rfm_analysis`
where rfm_segment is null



  
  
      
    ) dbt_internal_test