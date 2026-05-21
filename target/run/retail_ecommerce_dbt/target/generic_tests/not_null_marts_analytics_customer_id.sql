
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select customer_id
from `ga4-project-496021`.`ga4_data_marts`.`marts_analytics`
where customer_id is null



  
  
      
    ) dbt_internal_test