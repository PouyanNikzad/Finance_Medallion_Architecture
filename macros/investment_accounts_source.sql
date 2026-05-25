{% macro invest_source_sql(src_relation, institute_name, product_name) %}
  {#-
    src_relation: pass a relation like source('raw','table') or ref('stg_table')
    institute_name, product_name: strings
  -#}


  {% set institute_lit = sql_string_literal(institute_name) %}
  {% set product_lit   = sql_string_literal(product_name) %}


{% set sql %}
with src as (
    select
        {{ dbt_utils.generate_surrogate_key([
            "upper(trim(SYMBOL))",
            "upper(trim(MARKET))",
            "AVERAGE_COST"
        ]) }} as TRANSACTIONS_hKey,

        {{ dbt_utils.generate_surrogate_key([
            "to_varchar(try_to_number(QUANTITY, 38, 8))",
            "to_varchar(try_to_number(PRICE, 38, 8))",
            "to_varchar(try_to_number(AVERAGE_COST, 38, 8))"
        ]) }} as TRANSACTIONS_hdiff,

        t.*,
        {{ institute_lit }} as INISTITUE_SCHEMA_NAME,
        {{ product_lit }}   as PRODUCT_NAME,
        current_timestamp() as STAGING_INSERT_TIME
    from {{ src_relation }} t
),

latest_hash as (
    {% if is_incremental() %}
    select
        t.TRANSACTIONS_hKey,
        t.TRANSACTIONS_hdiff  
    from {{ this }} t  {#  {{this}} is the target table -#}   
    qualify row_number() over (
        partition by TRANSACTIONS_hKey
        order by STAGING_INSERT_TIME desc
    ) = 1
    {% else %}
    select
        null as TRANSACTIONS_hKey,
        null as TRANSACTIONS_hdiff
    {% endif %}
)

select s.*
from src s
left join latest_hash h
  on s.TRANSACTIONS_hKey = h.TRANSACTIONS_hKey
where h.TRANSACTIONS_hKey is null
   or s.TRANSACTIONS_hdiff <> h.TRANSACTIONS_hdiff


{% endset %}

{{ return(sql) }}
{% endmacro %}




