{% test no_hash_collision(model, hash_column, hashed_fields) %}

{# hashed_fields should be a list of column names: ['symbol','market','avg_cost'] #}
{% set fields_source = hashed_fields | join(', ') %}

with all_tuples as (
    select distinct
        {{ hash_column }} as hash,
        {{ fields_source }}
    from {{ model }}
),

validation_errors as (
    select
        hash,
        count(*) as distinct_tuple_count
    from all_tuples
    group by hash
    having count(*) > 1
)

select *
from validation_errors

{% endtest %}
