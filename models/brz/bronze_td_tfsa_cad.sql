{{ config(
    materialized='incremental',
    unique_key='TRAN_TD_CAD_TFSA_INVEST_TRANSACTIONS_hKey',
    incremental_strategy='merge'
) }}

with src as (
    select
        {{ dbt_utils.generate_surrogate_key([
            "upper(trim(SYMBOL))",
            "upper(trim(MARKET))"
        ]) }} as TRAN_TD_CAD_TFSA_INVEST_TRANSACTIONS_hKey,

        {{ dbt_utils.generate_surrogate_key([
            "to_varchar(try_to_number(QUANTITY, 38, 8))",
            "to_varchar(try_to_number(PRICE, 38, 8))",
            "to_varchar(try_to_number(AVERAGE_COST, 38, 8))"
        ]) }} as TRAN_TD_CAD_TFSA_INVEST_TRANSACTIONS_hdiff,

        t.*,

        'TD' as INISTITUE_SCHEMA_NAME,
        'TD TFSA CAD Direct Investment' as PRODUCT_NAME,
        current_timestamp() as STAGING_INSERT_TIME

    from {{ source("raw_finance_transactions","TD_CAD_TFSA_INVEST_TRANSACTIONS") }} t
),

-- only needed for incremental runs
latest_target as (
    {% if is_incremental() %}
    select
        TRAN_TD_CAD_TFSA_INVEST_TRANSACTIONS_hKey,
        max(STAGING_INSERT_TIME) as max_time
    from {{ this }}
    group by 1
    {% else %}
    select null as TRAN_TD_CAD_TFSA_INVEST_TRANSACTIONS_hKey, null as max_time
    {% endif %}
),

-- get most recent hashdiff per hKey in target
latest_hash as (
    {% if is_incremental() %}
    select
        t.TRAN_TD_CAD_TFSA_INVEST_TRANSACTIONS_hKey,
        t.TRAN_TD_CAD_TFSA_INVEST_TRANSACTIONS_hdiff
    from {{ this }} t
    qualify row_number() over (
        partition by TRAN_TD_CAD_TFSA_INVEST_TRANSACTIONS_hKey
        order by STAGING_INSERT_TIME desc
    ) = 1
    {% else %}
    select
        null as TRAN_TD_CAD_TFSA_INVEST_TRANSACTIONS_hKey,
        null as TRAN_TD_CAD_TFSA_INVEST_TRANSACTIONS_hdiff
    {% endif %}
)

select s.*
from src s
left join latest_hash h
  on s.TRAN_TD_CAD_TFSA_INVEST_TRANSACTIONS_hKey = h.TRAN_TD_CAD_TFSA_INVEST_TRANSACTIONS_hKey
where
    -- first time seen OR changed attributes
    h.TRAN_TD_CAD_TFSA_INVEST_TRANSACTIONS_hKey is null
    or s.TRAN_TD_CAD_TFSA_INVEST_TRANSACTIONS_hdiff <> h.TRAN_TD_CAD_TFSA_INVEST_TRANSACTIONS_hdiff