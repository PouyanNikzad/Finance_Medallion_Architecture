with cte as (
select
  {{ dbt_utils.generate_surrogate_key([
      'transaction_date',
      'merchant_name',
      "coalesce(credit,debit)"
  ]) }} as TRAN_TD_AEROPLAN_VISA_INFINITE_hKey,
  *
from {{ source('raw_finance_transactions', 'TD_AEROPLAN_VISA_INFINITE') }}
)
select * from cte 
qualify row_number() over (partition by TRAN_TD_AEROPLAN_VISA_INFINITE_hKey order by (select 0))=1