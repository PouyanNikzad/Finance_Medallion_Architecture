{{ config(materialized='table') }}

with base_dates as (
    {{ dbt.date_spine(
        'day',
        "DATE('2020-01-01')",
        "DATE('2035-01-01')"
    ) }}
)

select cast(date_day as date) as date_day
from base_dates