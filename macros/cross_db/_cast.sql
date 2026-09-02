{#
    Xavfsiz (fail-safe) cast.

    NEGA KERAK:
      Xom (raw) manbada bitta buzilgan qiymat butun modelni yiqitadi.
      Masalan pinfl_birth_date() ichidagi cast(... as date) — agar
      manbada '00000000000000' kabi PINFL bo'lsa, Postgres butun
      so'rovni xato bilan to'xtatadi va model qurilmaydi.

      Prod'da manba ma'lumoti HAR DOIM iflos bo'ladi — shuning uchun
      "bitta yomon qator butun pipeline'ni to'xtatmasin" tamoyili.

    QO'LLAB-QUVVATLASH:
      Snowflake / Spark / Databricks : TRY_CAST
      BigQuery                       : SAFE_CAST
      ClickHouse                     : accurateCastOrNull
      PostgreSQL / Redshift          : TRY_CAST YO'Q (!)

      Postgres va Redshift'da xavfsiz cast mavjud emas, shu sababli
      u yerda oddiy CAST qaytariladi. Bu omborlarda chaqiruvchi macro
      qiymatni CASE ichida OLDINDAN tekshirishi SHART — masalan
      pinfl_birth_date() aynan shunday qiladi (is_valid_pinfl + oy/kun
      diapazoni tekshiruvi). CASE shoxlari ustunga bog'liq bo'lgani
      uchun Postgres ularni dangasa (lazy) baholaydi.
#}

{% macro uz_safe_cast(expression, type) -%}
  {{ return(adapter.dispatch('uz_safe_cast', 'uz_utils')(expression, type)) }}
{%- endmacro %}

{% macro default__uz_safe_cast(expression, type) -%}
  try_cast({{ expression }} as {{ type }})
{%- endmacro %}

{% macro bigquery__uz_safe_cast(expression, type) -%}
  safe_cast({{ expression }} as {{ type }})
{%- endmacro %}

{% macro clickhouse__uz_safe_cast(expression, type) -%}
  accurateCastOrNull({{ expression }}, '{{ type }}')
{%- endmacro %}

{#- Postgres/Redshift: TRY_CAST yo'q — chaqiruvchi CASE bilan himoyalashi kerak -#}
{% macro postgres__uz_safe_cast(expression, type) -%}
  cast({{ expression }} as {{ type }})
{%- endmacro %}

{% macro redshift__uz_safe_cast(expression, type) -%}
  cast({{ expression }} as {{ type }})
{%- endmacro %}
