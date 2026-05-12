{% snapshot bank_products_snapshot %}

{{ config(
    target_schema='snapshots',
    unique_key='BANK_PRODUCT_ID',
    strategy='check', 
    check_cols=['PRODUCT_NAME','IS_ACTIVE']
) }}

SELECT * FROM {{ source("raw_finance_dimensions","BANK_PRODUCTS") }}

{% endsnapshot %}