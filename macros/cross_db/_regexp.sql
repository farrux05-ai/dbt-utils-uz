{#
    Ombor (warehouse) turiga qarab to'g'ri regex funksiyasini tanlaydi.
    dbt_utils'dagi adapter.dispatch patterniga o'xshab qurilgan — yangi
    ombor qo'shish uchun shu faylga <adapter_name>__uz_regexp_* macro qo'shing.
#}

{% macro uz_regexp_like(column, pattern) -%}
  {{ return(adapter.dispatch('uz_regexp_like', 'uz_utils')(column, pattern)) }}
{%- endmacro %}

{% macro default__uz_regexp_like(column, pattern) -%}
  regexp_like({{ column }}, '{{ pattern }}')
{%- endmacro %}

{% macro postgres__uz_regexp_like(column, pattern) -%}
  ({{ column }} ~ '{{ pattern }}')
{%- endmacro %}

{% macro redshift__uz_regexp_like(column, pattern) -%}
  ({{ column }} ~ '{{ pattern }}')
{%- endmacro %}

{% macro bigquery__uz_regexp_like(column, pattern) -%}
  regexp_contains({{ column }}, r'{{ pattern }}')
{%- endmacro %}

{% macro spark__uz_regexp_like(column, pattern) -%}
  {{ column }} rlike '{{ pattern }}'
{%- endmacro %}

{% macro databricks__uz_regexp_like(column, pattern) -%}
  {{ column }} rlike '{{ pattern }}'
{%- endmacro %}

{% macro clickhouse__uz_regexp_like(column, pattern) -%}
  match({{ column }}, '{{ pattern }}')
{%- endmacro %}


{% macro uz_regexp_replace(column, pattern, replacement="") -%}
  {{ return(adapter.dispatch('uz_regexp_replace', 'uz_utils')(column, pattern, replacement)) }}
{%- endmacro %}

{% macro default__uz_regexp_replace(column, pattern, replacement) -%}
  regexp_replace({{ column }}, '{{ pattern }}', '{{ replacement }}')
{%- endmacro %}

{% macro postgres__uz_regexp_replace(column, pattern, replacement) -%}
  regexp_replace({{ column }}, '{{ pattern }}', '{{ replacement }}', 'g')
{%- endmacro %}

{% macro redshift__uz_regexp_replace(column, pattern, replacement) -%}
  regexp_replace({{ column }}, '{{ pattern }}', '{{ replacement }}')
{%- endmacro %}

{% macro bigquery__uz_regexp_replace(column, pattern, replacement) -%}
  regexp_replace({{ column }}, r'{{ pattern }}', '{{ replacement }}')
{%- endmacro %}

{% macro spark__uz_regexp_replace(column, pattern, replacement) -%}
  regexp_replace({{ column }}, '{{ pattern }}', '{{ replacement }}')
{%- endmacro %}

{% macro databricks__uz_regexp_replace(column, pattern, replacement) -%}
  regexp_replace({{ column }}, '{{ pattern }}', '{{ replacement }}')
{%- endmacro %}

{% macro clickhouse__uz_regexp_replace(column, pattern, replacement) -%}
  replaceRegexpAll({{ column }}, '{{ pattern }}', '{{ replacement }}')
{%- endmacro %}
