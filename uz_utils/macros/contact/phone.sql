{#
    O'zbekiston telefon raqamlarini +998XXXXXXXXX formatiga keltiradi.
    Kiruvchi format turlicha bo'lishi mumkin, masalan:
      998901234567 / +998 90 123 45 67 / 0901234567 / 901234567

    Operator kodlari (raqamning +998 dan keyingi 2 xonasi): 90, 91, 93,
    94, 95, 97, 98, 99, 88, 77, 33 va h.k. — bular vaqti-vaqti bilan
    yangilanadi, shu sababli bu paket faqat kodni AJRATIB OLADI, uni
    operator nomiga map qilish alohida (o'zgaruvchan) ma'lumotnoma sifatida
    integration_tests yoki seed orqali qo'shilishi kerak.
#}

{% macro normalize_uz_phone(column) -%}
  {%- set digits -%}
    {{ uz_utils.uz_regexp_replace(column, '[^0-9]', '') }}
  {%- endset -%}
  case
    when {{ uz_utils.uz_regexp_like(digits, '^998[0-9]{9}$') }}
      then concat('+', {{ digits }})
    when {{ uz_utils.uz_regexp_like(digits, '^[0-9]{9}$') }}
      then concat('+998', {{ digits }})
    when {{ uz_utils.uz_regexp_like(digits, '^0[0-9]{9}$') }}
      then concat('+998', substring({{ digits }}, 2, 9))
    else null
  end
{%- endmacro %}


{% macro uz_phone_operator(column) -%}
  substring({{ uz_utils.normalize_uz_phone(column) }}, 5, 2)
{%- endmacro %}
