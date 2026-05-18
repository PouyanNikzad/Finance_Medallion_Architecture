with cte as 
(
select
  {{ dbt_utils.generate_surrogate_key([
      'transaction_date',
      'merchant_name',
      "coalesce(credit,debit)"
  ]) }} as TRANSACTIONS_hKey,
  	TRANSACTION_DATE,
	MERCHANT_NAME,
	CREDIT,
	DEBIT,
	END_BALANCE,
    'CONEXUS' as INISTITUE_SCHEMA_NAME,
    'CONEXUS_DEBIT_CARD' as PRODUCT_NAME,
    current_timestamp() as STAGING_INSERT_TIME
    from {{ source("raw_finance_transactions","CONEXUS_DEBIT_CARD_TRANSACTIONS") }} t

    {% if is_incremental() %}
      where t.TRANSACTION_DATE >= dateadd(day, -7, (select coalesce(max(transaction_date), '1900-01-01') from {{ this }})
      )
    {% endif %}
),

deduped as (
    select *
    from cte
    qualify 
        row_number() over (
        partition by TRANSACTIONS_hKey
        order by STAGING_INSERT_TIME desc
    ) = 1
)

select * from deduped