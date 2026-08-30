{#
    Cross-database hafta kuni (day-of-week) funksiyasi.
    Barcha adapterlar uchun bir xil natija qaytaradi:
      1 = Dushanba
      2 = Seshanba
      3 = Chorshanba
      4 = Payshanba
      5 = Juma
      6 = Shanba
      7 = Yakshanba

    Bu macro uz_utils.is_working_day() tomonidan ishlatiladi.
    Yangi adapter qo'shish uchun shu faylga <adapter>__uz_dayofweek qo'shing.
#}

{% macro uz_dayofweek(column) -%}
  {{ return(adapter.dispatch('uz_dayofweek', 'uz_utils')(column)) }}
{%- endmacro %}

{# Snowflake: DAYOFWEEKISO — 1=Du, 7=Ya ✓ #}
{% macro default__uz_dayofweek(column) -%}
  dayofweekiso({{ column }})
{%- endmacro %}

{# PostgreSQL: extract(isodow ...) — 1=Du, 7=Ya ✓ #}
{% macro postgres__uz_dayofweek(column) -%}
  extract(isodow from {{ column }})
{%- endmacro %}

{# Redshift: extract(isodow ...) — 1=Du, 7=Ya ✓ #}
{% macro redshift__uz_dayofweek(column) -%}
  extract(isodow from {{ column }})
{%- endmacro %}

{#
    BigQuery: EXTRACT(DAYOFWEEK ...) — 1=Ya, 7=Sha (ISO emas!)
    Konversiya: 1(Ya)→7, boshqalar: val-1
#}
{% macro bigquery__uz_dayofweek(column) -%}
  case extract(dayofweek from {{ column }})
    when 1 then 7
    else extract(dayofweek from {{ column }}) - 1
  end
{%- endmacro %}

{#
    Spark: dayofweek() — 1=Ya, 7=Sha (ISO emas!)
    Konversiya: 1(Ya)→7, boshqalar: val-1
#}
{% macro spark__uz_dayofweek(column) -%}
  case dayofweek({{ column }})
    when 1 then 7
    else dayofweek({{ column }}) - 1
  end
{%- endmacro %}

{% macro databricks__uz_dayofweek(column) -%}
  case dayofweek({{ column }})
    when 1 then 7
    else dayofweek({{ column }}) - 1
  end
{%- endmacro %}

{# ClickHouse: toDayOfWeek() — 1=Du, 7=Ya ✓ #}
{% macro clickhouse__uz_dayofweek(column) -%}
  toDayOfWeek({{ column }})
{%- endmacro %}
