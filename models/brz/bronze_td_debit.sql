{{ config(
    materialized='incremental',
    unique_key='TD_DEBIT_CARD_TRANSACTIONS_hKey',
    incremental_strategy='merge'
) }}

with cte as (
select
  {{ dbt_utils.generate_surrogate_key([
      'transaction_date',
      'merchant_name',
      "coalesce(credit,debit)"
  ]) }} as TD_DEBIT_CARD_TRANSACTIONS_hKey,
  t.*
  ,'TD' as INISTITUE_SCHEMA_NAME,'TD_DEBIT_CARD_CAD' as PRODUCT_NAME,current_timestamp() as STAGING_INSERT_TIME
from {{ source("raw_finance_transactions","TD_DEBIT_CARD_TRANSACTIONS") }} t

    {% if is_incremental() %}
      -- Lookback window to capture late-arriving records
      where t.transaction_date >= dateadd(
          day, -7,
          (select coalesce(max(transaction_date), '1900-01-01') from {{ this }})
      )
    {% endif %}
),
deduped as (
    select *
    from cte
    qualify row_number() over (
        partition by TD_DEBIT_CARD_TRANSACTIONS_hKey
        order by STAGING_INSERT_TIME desc
    ) = 1
)
select * from deduped