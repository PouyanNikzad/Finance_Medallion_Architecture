{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='TRAN_TD_CAD_TFSA_INVEST_TRANSACTIONS_hKey'
) }}

with src as (

    select
        {{ dbt_utils.generate_surrogate_key([
            "upper(trim(SYMBOL))",
            "upper(trim(MARKET))",
            "to_varchar(try_to_number(QUANTITY, 38, 8))",
            "to_varchar(try_to_number(PRICE, 38, 8))"
        ]) }} as TRAN_TD_CAD_TFSA_INVEST_TRANSACTIONS_hKey,

        t.*,

        'TD' as INISTITUE_SCHEMA_NAME,
        'TD TFSA CAD Direct Investment' as PRODUCT_NAME,
        current_timestamp() as STAGING_INSERT_TIME

    from {{ source("raw_finance_transactions","TD_CAD_TFSA_INVEST_TRANSACTIONS") }} t
),

deduped as (

    select *
    from src
    qualify row_number() over (
        partition by TRAN_TD_CAD_TFSA_INVEST_TRANSACTIONS_hKey
        order by STAGING_INSERT_TIME desc
    ) = 1
)

select * from deduped