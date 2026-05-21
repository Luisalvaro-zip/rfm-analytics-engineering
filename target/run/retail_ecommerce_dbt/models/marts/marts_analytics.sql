
  
    

    create or replace table `ga4-project-496021`.`ga4_data_marts`.`marts_analytics`
      
    
    

    
    OPTIONS()
    as (
      -- Configuramos la materialización como tabla física en BigQuery


with customer_metrics as (
    -- Leemos directamente de tu capa intermedia recién creada
    select * from `ga4-project-496021`.`ga4_data_intermediate`.`int_customer_metrics`
),

rfm_scoring as (
    select
        customer_id,
        recency_days,
        frequency_count,
        monetary_value,
        
        -- SCORING DE RECENCIA: Menos días = Mejor puntaje (5)
        ntile(5) over (order by recency_days desc) as r_score,
        
        -- SCORING DE FRECUENCIA: Más compras = Mejor puntaje (5)
        ntile(5) over (order by frequency_count asc) as f_score,
        
        -- SCORING DE MONETARIO: Más gasto = Mejor puntaje (5)
        ntile(5) over (order by monetary_value asc) as m_score

    from customer_metrics
),

rfm_segmentation as (
    select
        *,
        -- Creamos un identificador único de celda (ej. "555", "112")
        concat(cast(r_score as string), cast(f_score as string), cast(m_score as string)) as rfm_cell,
        
        -- Definición de segmentos de negocio basados en los scores
        case
            -- Clientes top: compran seguido, recientemente y gastan mucho
            when r_score >= 4 and f_score >= 4 and m_score >= 4 then 'Campeones'
            
            -- Compran seguido y responden a estímulos, pero no tan reciente
            when r_score >= 2 and f_score >= 3 and m_score >= 3 then 'Clientes Leales'
            
            -- Compraron hace muy poco pero tienen baja frecuencia
            when r_score >= 4 and f_score <= 2 then 'Nuevos Clientes'
            
            -- Grandes compradores históricos que están dejando de venir
            when r_score <= 2 and f_score >= 4 and m_score >= 4 then 'No Podemos Perderlos'
            
            -- Clientes con puntajes bajos en todo
            when r_score <= 2 and f_score <= 2 then 'Hibernando / Perdidos'
            
            -- Clientes promedio que no caen en categorías extremas
            else 'Regulares / Potenciales'
        end as rfm_segment

    from rfm_scoring
)

select * from rfm_segmentation
    );
  