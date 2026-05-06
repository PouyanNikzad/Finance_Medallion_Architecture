{{ config(materialized='table') }}

select * from {{source("raw_finance_dimensions","BANK_ACCOUNT")}}