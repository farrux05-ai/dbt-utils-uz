{#
    Bank MFO (Moliya-Hisob Operatsiyalari) kodi bilan ishlash.
    O'zbekistonda har bir bankka 5 xonali MFO kodi berilgan.

    is_valid_mfo:
      Format tekshiruvi: aynan 5 ta raqam.
      Misol: '00873' → true, '873' → false, 'ABCDE' → false, null → false.

    mfo_to_bank_name / mfo_to_bank_short:
      uz_banks seed'i orqali bank nomini qaytaradi.
      Agar MFO kodi uz_banks'da topilmasa — null qaytadi.
      Foydalanish: {{ uz_utils.mfo_to_bank_name('mfo_column') }}

      DIQQAT: v0.3'dan boshlab bu macro'lar correlated subquery emas,
      compile-time'da yaratilgan INLINE CASE ifodasini qaytaradi —
      sabablari uchun macros/cross_db/_seed.sql'ga qarang.
      Shu sababli modeldan oldin `dbt seed` (yoki `dbt build`) ishlashi shart.

    DIQQAT:
      uz_banks seed'i to'liq rasmiy ro'yxat EMAS — ochiq manbalarga
      asoslangan. To'liq va yangilangan ro'yxat uchun O'zR Markaziy
      banki (cbu.uz) saytiga murojaat qiling.
      Yangi bankni qo'shish uchun uz_banks.csv'ga PR yuboring.
#}


{% macro is_valid_mfo(column) -%}
  coalesce({{ uz_utils.uz_regexp_like(column, '^[0-9]{5}$') }}, false)
{%- endmacro %}


{#- Ichki yordamchi: MFO → ustun qiymati CASE ifodasini quradi. -#}
{% macro _uz_mfo_lookup(column, value_column) -%}
  {%- set rows = uz_utils.uz_seed_rows('uz_banks', ['mfo_code', value_column]) -%}
  {%- if rows | length == 0 -%}
    cast(null as {{ dbt.type_string() }})
  {%- else -%}
  case {{ column }}
    {%- for row in rows %}
    {% if row[1] is not none %}when {{ uz_utils.uz_quote_literal(row[0]) }} then {{ uz_utils.uz_quote_literal(row[1]) }}{% endif %}
    {%- endfor %}
    else null
  end
  {%- endif -%}
{%- endmacro %}


{% macro mfo_to_bank_name(column) -%}
  ( {{ uz_utils._uz_mfo_lookup(column, 'bank_name_uz') }} )
{%- endmacro %}


{% macro mfo_to_bank_short(column) -%}
  ( {{ uz_utils._uz_mfo_lookup(column, 'bank_short') }} )
{%- endmacro %}
