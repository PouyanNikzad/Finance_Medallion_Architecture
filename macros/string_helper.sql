{% macro sql_string_literal(val) -%}
  {# Returns a Snowflake-safe SQL string literal #}
  '{{ (val | string) | replace("'", "''") }}'
{%- endmacro %}
