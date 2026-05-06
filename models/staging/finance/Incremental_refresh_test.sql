{{ config(
    materialized='incremental',
    unique_key='TRAN_TD_AEROPLAN_VISA_INFINITE_hKey'
) }}

select *
from {{ref("bronze_td_aeroplane_visa_infinite")}}

{% if is_incremental() %}
where transaction_date > (select max(transaction_date) from {{ this }})
{% endif %}