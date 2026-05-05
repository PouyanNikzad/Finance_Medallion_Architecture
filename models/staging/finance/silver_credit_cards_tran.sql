select
  tr.*,
  ba.institution_name
from {{ ref('bronze_td_aeroplane_visa_infinite') }} as tr
left join {{ source('raw_finance_dimensions', 'BANK_ACCOUNT') }} as ba
  on tr.INISTITUE_SCHEMA_NAME = ba.institution_assigned_schema