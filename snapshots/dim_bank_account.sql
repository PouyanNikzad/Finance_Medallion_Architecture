{% snapshot bank_account_snapshot %}

{{ config(
    target_schema='snapshots',
    unique_key='bank_id',
    strategy='check', 
    check_cols=['INSTITUTION_NAME','branch_name','branch_city']
) }}

SELECT * FROM {{ source("raw_finance_dimensions",'BANK_ACCOUNT') }}

{% endsnapshot %}