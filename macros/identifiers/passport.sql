{#
    O'zbekiston pasporti — 2 ta lotin harfi (A-Z) va 7 ta raqam.
    Rasmiy format: "AA 1234567" (bo'sh joy bilan).

    is_valid_passport:
      Tekshiradi: faqat normallanmagan (uppercase, bo'sh joyli) holat.
      Agar "AB 1234567" kabi bo'lsa — true.
      "ab1234567", "AB-1234567" kabi bo'lsa — false (normalize qilish kerak).

    normalize_passport:
      Har qanday formatni "AB 1234567" standart ko'rinishiga keltiradi:
        "ab1234567"   →  "AB 1234567"
        "AB-1234567"  →  "AB 1234567"
        "AB 1234567"  →  "AB 1234567"
        "1B 1234567"  →  null   (birinchi xona raqam — noto'g'ri)
        "ABC1234567"  →  null   (3 harf — noto'g'ri)

    DIQQAT: Passport seriyasi haqiqiy registrda mavjudligini tekshirmaydi,
    faqat FORMAT nazorat qilinadi.
#}


{% macro is_valid_passport(column) -%}
  {#- Standart ko'rinish: "AB 1234567" — 2 bosh harf, bo'sh joy, 7 raqam -#}
  {{ uz_utils.uz_regexp_like(column, '^[A-Z]{2} [0-9]{7}$') }}
{%- endmacro %}


{% macro normalize_passport(column) -%}
  {#-
      1. Harflar va raqamlardan boshqa belgilarni olib tashlaymiz
      2. Natija aynan 9 belgi (2 harf + 7 raqam) bo'lishi kerak
      3. Bosh harfga o'tkazib, o'rtaga bo'sh joy qo'shamiz
  -#}
  {%- set stripped -%}
    {{ uz_utils.uz_regexp_replace(column, '[^A-Za-z0-9]', '') }}
  {%- endset -%}
  case
    when {{ uz_utils.uz_regexp_like(stripped, '^[A-Za-z]{2}[0-9]{7}$') }}
      then concat(
        upper(substring({{ stripped }}, 1, 2)),
        ' ',
        substring({{ stripped }}, 3, 7)
      )
    else null
  end
{%- endmacro %}
