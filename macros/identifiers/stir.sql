{#
    STIR / INN — yuridik shaxs (biznes)ning 9 xonali soliq identifikatsiya
    raqami. Tuzilishi: 8 ta asosiy raqam + 1 ta nazorat (check) raqam.

    DIQQAT (v0.1 cheklovi): rasmiy nazorat raqami formulasi ochiq
    manbalarda tasdiqlanmagan holda topilmadi. Shu sababli hozircha
    faqat FORMAT tekshiriladi (aynan 9 ta raqam), checksum yo'q.

    Agar real (tasdiqlangan) STIR namunalari to'plami mavjud bo'lsa,
    checksum formulasini reverse-engineering qilib shu yerga qo'shish
    mumkin — bu keyingi versiya uchun TODO.
#}

{% macro is_valid_stir(column) -%}
  coalesce({{ uz_utils.uz_regexp_like(column, '^[0-9]{9}$') }}, false)
{%- endmacro %}
