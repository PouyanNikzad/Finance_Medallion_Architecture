select TR.*,BA.INSTITUTION_NAME 
from ref("bronze_td_aeroplane_visa_infinite") TR
left join source("raw_finance_dimensions","BANK_ACCOUNT") BA
on TR.INISTITUE_SCHEMA_NAME=BA.INSTITUTION_ASSIGNED_SCHEMA