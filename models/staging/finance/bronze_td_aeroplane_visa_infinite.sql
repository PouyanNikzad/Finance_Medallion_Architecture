select
  {{ dbt_utils.generate_surrogate_key([
      'transaction_date',
      'merchant_name',
      "coalesce(credit,debit)"
  ]) }} as TRAN_TD_AEROPLAN_VISA_INFINITE_hKey,
  *
from {{ source('raw_finance_transactions', 'TD_AEROPLAN_VISA_INFINITE') }}