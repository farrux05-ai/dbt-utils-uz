{#
    Bank MFO (Moliya-Hisob Operatsiyalari) kodi bilan ishlash.
    O'zbekistonda har bir bankka 5 xonali MFO kodi berilgan.

    is_valid_mfo:
      Format tekshiruvi: aynan 5 ta raqam.
      Misol: '00873' → true, '873' → false, 'ABCDE' → false.

    mfo_to_bank_name:
      uz_banks seed'i orqali bank nomini qaytaradi.
      Agar MFO kodi uz_banks'da topilmasa — null qaytadi.
      Foydalanish: {{ uz_utils.mfo_to_bank_name('mfo_column') }}

    DIQQAT:
      uz_banks seed'i to'liq rasmiy ro'yxat EMAS — ochiq manbalarga
      asoslangan. To'liq va yangilangan ro'yxat uchun O'zR Markaziy
      banki (cbu.uz) saytiga murojaat qiling.
      Yangi bankni qo'shish uchun uz_banks.csv'ga PR yuboring.
#}


{% macro is_valid_mfo(column) -%}
  {{ uz_utils.uz_regexp_like(column, '^[0-9]{5}$') }}
{%- endmacro %}


{% macro mfo_to_bank_name(column) -%}
  (
    select bank_name_uz
    from {{ ref('uz_utils', 'uz_banks') }}
    where mfo_code = {{ column }}
    limit 1
  )
{%- endmacro %}


{% macro mfo_to_bank_short(column) -%}
  (
    select bank_short
    from {{ ref('uz_utils', 'uz_banks') }}
    where mfo_code = {{ column }}
    limit 1
  )
{%- endmacro %}
