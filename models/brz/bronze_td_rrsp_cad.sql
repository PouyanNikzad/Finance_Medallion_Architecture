with src as (
    select
        {{ dbt_utils.generate_surrogate_key([
            "upper(trim(SYMBOL))",
            "upper(trim(MARKET))"
        ]) }} as TRANSACTIONS_hKey,

        {{ dbt_utils.generate_surrogate_key([
            "to_varchar(try_to_number(QUANTITY, 38, 8))",
            "to_varchar(try_to_number(PRICE, 38, 8))",
            "to_varchar(try_to_number(AVERAGE_COST, 38, 8))"
        ]) }} as TRAN_TD_CAD_RRSP_INVEST_TRANSACTIONS_hdiff,

        t.*,

        'TD' as INISTITUE_SCHEMA_NAME,
        'TD RRSP CAD Direct Investment' as PRODUCT_NAME,
        current_timestamp() as STAGING_INSERT_TIME

    from {{ source("raw_finance_transactions","TD_CAD_RRSP_INVEST_TRANSACTIONS") }} t
),
-- get most recent hashdiff per hKey in target
latest_hash as (
    {% if is_incremental() %}
    select
        t.TRANSACTIONS_hKey,
        t.TRAN_TD_CAD_RRSP_INVEST_TRANSACTIONS_hdiff
    from {{ this }} t
    qualify row_number() over (
        partition by TRANSACTIONS_hKey
        order by STAGING_INSERT_TIME desc
    ) = 1
    {% else %}
    select
        null as TRANSACTIONS_hKey,
        null as TRAN_TD_CAD_RRSP_INVEST_TRANSACTIONS_hdiff
    {% endif %}
)

select s.*
from src s
left join latest_hash h
  on s.TRANSACTIONS_hKey = h.TRANSACTIONS_hKey
where
    -- first time seen OR changed attributes
    h.TRANSACTIONS_hKey is null
    or s.TRAN_TD_CAD_RRSP_INVEST_TRANSACTIONS_hdiff <> h.TRAN_TD_CAD_RRSP_INVEST_TRANSACTIONS_hdiff