{#
    PINFL / JSHSHIR — jismoniy shaxsning 14 xonali identifikatsiya raqami.

    Tuzilishi (1-pozitsiya chapdan boshlab hisoblanadi):
      1-pozitsiya    (1 raqam): asr + jins indeksi
                                 1/2 -> 1800-1899 yillar
                                 3/4 -> 1900-1999 yillar
                                 5/6 -> 2000-2099 yillar
                                 toq qiymat -> erkak, juft qiymat -> ayol
      2-7 pozitsiya  (6 raqam): tug'ilgan sana, ddmmyy formatida
      8-10 pozitsiya (3 raqam): hudud kodi
      11-13 pozitsiya(3 raqam): tartib raqami
      14-pozitsiya   (1 raqam): nazorat raqami

    DIQQAT: nazorat raqami (14-pozitsiya) formulasi ochiq manbada
    topilmadi, shu sababli bu yerda tekshirilmaydi — faqat format va
    1-pozitsiya qiymati (1-6 oralig'ida) tekshiriladi.

    ─────────────────────────────────────────────────────────────────
    NULL SEMANTIKASI (butun paket bo'ylab yagona shartnoma)
    ─────────────────────────────────────────────────────────────────
      is_valid_*  → HECH QACHON null qaytarmaydi. null kirish → false.
                    Sabab: `where not is_valid_pinfl(x)` kabi filtr
                    aks holda null qatorlarni JIMGINA tashlab ketadi.
      boshqa      → yaroqsiz kirish uchun null qaytaradi.
#}

{% macro is_valid_pinfl(column) -%}
  coalesce(
    (
      {{ uz_utils.uz_regexp_like(column, '^[0-9]{14}$') }}
      and substring({{ column }}, 1, 1) in ('1','2','3','4','5','6')
    ),
    false
  )
{%- endmacro %}


{% macro pinfl_gender(column) -%}
  {#- Yaroqsiz PINFL'da cast(... as int) xato bermasligi uchun
      avval is_valid_pinfl bilan himoyalanadi. -#}
  case
    when not {{ uz_utils.is_valid_pinfl(column) }} then null
    when mod(cast(substring({{ column }}, 1, 1) as {{ dbt.type_int() }}), 2) = 1
      then 'erkak'
    else 'ayol'
  end
{%- endmacro %}


{% macro pinfl_birth_date(column) -%}
  {#
      Misol: PINFL '3' + '121063' -> asr 1900, dd=12, mm=10, yy=63
             -> tug'ilgan sana 1963-10-12

      XAVFSIZLIK: format tekshirilmasdan cast(... as date) qilinsa,
      manbadagi BITTA buzilgan PINFL butun modelni yiqitadi
      (masalan oy = '99'). Shu sababli:
        1. is_valid_pinfl  — 14 raqam va to'g'ri asr indeksi;
        2. oy 01-12, kun 01-31 diapazonida ekanligi;
        3. qolgan chekka holatlar uchun (masalan 31-fevral)
           uz_safe_cast — TRY_CAST/SAFE_CAST bor omborlarda null qaytaradi.
  #}
  {%- set dd -%}substring({{ column }}, 2, 2){%- endset -%}
  {%- set mm -%}substring({{ column }}, 4, 2){%- endset -%}
  {%- set yy -%}substring({{ column }}, 6, 2){%- endset -%}

  {%- set date_string -%}
    concat(
      cast(
        (
          case substring({{ column }}, 1, 1)
            when '1' then 1800 when '2' then 1800
            when '3' then 1900 when '4' then 1900
            when '5' then 2000 when '6' then 2000
          end
          + cast({{ yy }} as {{ dbt.type_int() }})
        ) as {{ dbt.type_string() }}
      ),
      '-', {{ mm }},
      '-', {{ dd }}
    )
  {%- endset -%}

  case
    when not {{ uz_utils.is_valid_pinfl(column) }} then null
    when {{ mm }} not between '01' and '12' then null
    when {{ dd }} not between '01' and '31' then null
    else {{ uz_utils.uz_safe_cast(date_string, 'date') }}
  end
{%- endmacro %}


{% macro pinfl_region_code(column) -%}
  case
    when {{ uz_utils.is_valid_pinfl(column) }}
      then substring({{ column }}, 8, 3)
    else null
  end
{%- endmacro %}
