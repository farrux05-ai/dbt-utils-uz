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
#}

{% macro is_valid_pinfl(column) -%}
  (
    {{ uz_utils.uz_regexp_like(column, '^[0-9]{14}$') }}
    and substring({{ column }}, 1, 1) in ('1','2','3','4','5','6')
  )
{%- endmacro %}


{% macro pinfl_gender(column) -%}
  case
    when mod(cast(substring({{ column }}, 1, 1) as {{ dbt.type_int() }}), 2) = 1
      then 'erkak'
    else 'ayol'
  end
{%- endmacro %}


{% macro pinfl_birth_date(column) -%}
  {#
      Misol: PINFL '3' + '121063' -> asr 1900, dd=12, mm=10, yy=63
             -> tug'ilgan sana 1963-10-12
      Diqqat: CAST(... AS DATE) sintaksisi barcha omborlarda 'YYYY-MM-DD'
      formatidagi satrni tanib oladi, lekin ishlatishdan oldin o'z
      warehouse'ingizda sinab ko'rish tavsiya etiladi.
  #}
  cast(
    concat(
      cast(
        (
          case substring({{ column }}, 1, 1)
            when '1' then 1800 when '2' then 1800
            when '3' then 1900 when '4' then 1900
            when '5' then 2000 when '6' then 2000
          end
          + cast(substring({{ column }}, 6, 2) as {{ dbt.type_int() }})
        ) as {{ dbt.type_string() }}
      ),
      '-', substring({{ column }}, 4, 2),
      '-', substring({{ column }}, 2, 2)
    ) as date
  )
{%- endmacro %}


{% macro pinfl_region_code(column) -%}
  substring({{ column }}, 8, 3)
{%- endmacro %}
