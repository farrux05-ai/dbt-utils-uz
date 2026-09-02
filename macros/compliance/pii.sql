{#
    PII (Shaxsiy Ma'lumotlar) himoyasi uchun maskalash macro'lari.
    O'zbekiston "Shaxsga doir ma'lumotlar to'g'risida"gi qonun (2019)
    va GDPR-ga o'xshash talablarni hisobga olgan holda ishlab chiqilgan.

    ┌──────────────────────────────────────────────────────────────────┐
    │  XAVFSIZLIK QOIDASI (fail-closed)                                │
    │  Bu yerdagi barcha macro'lar kirish qiymati kutilgan formatga    │
    │  MOS KELMASA — NULL qaytaradi, hech qachon xom (maskalanmagan)   │
    │  qiymatni qaytarmaydi. Maskalash funksiyasi "shubha bo'lsa —     │
    │  yashir" tamoyili asosida ishlashi shart.                        │
    └──────────────────────────────────────────────────────────────────┘

    mask_pinfl:
      Birinchi va oxirgi xonadan boshqasini yashiradi.
      '31234560012345'  →  '3************5'
      Yaroqsiz PINFL    →  null

    mask_phone:
      Operator kodini va oxirgi 3 xonani saqlaydi, qolganini yashiradi.
      '+998901234567'   →  '+99890****567'
      '+998931234567'   →  '+99893****567'   (operator kodi SAQLANADI)
      Normalize qilinmagan raqam uchun ham ishlaydi.

    mask_passport:
      Seriyani saqlaydi, raqamning faqat oxirgi 3 xonasini ko'rsatadi.
      'AB 1234567'  →  'AB ****567'

    mask_card_number — bu funksiya payments/card.sql'da allaqachon bor.

    FOYDALANISH TAVSIYASI:
      Bu macro'larni staging qatlaminizda qo'llang — PII ma'lumotlar
      mart qatlamiga yetib bormasin. Masalan:

        select
          customer_id,
          {{ uz_utils.mask_pinfl('pinfl') }}       as pinfl_masked,
          {{ uz_utils.mask_phone('raw_phone') }}    as phone_masked,
          {{ uz_utils.mask_passport('passport') }}  as passport_masked
        from {{ source('raw', 'customers') }}
#}


{% macro mask_pinfl(column) -%}
  case
    when {{ uz_utils.is_valid_pinfl(column) }}
      then concat(
        substring({{ column }}, 1, 1),
        '************',
        substring({{ column }}, 14, 1)
      )
    {#- fail-closed: yaroqsiz format xom holda O'TKAZILMAYDI -#}
    else null
  end
{%- endmacro %}


{% macro mask_phone(column) -%}
  {%- set normalized -%}
    {{ uz_utils.normalize_uz_phone(column) }}
  {%- endset -%}
  case
    when {{ normalized }} is not null
      then concat(
        '+998',
        substring({{ normalized }}, 5, 2),
        '****',
        substring({{ normalized }}, 11, 3)
      )
    else null
  end
{%- endmacro %}


{% macro mask_passport(column) -%}
  {%- set norm -%}
    {{ uz_utils.normalize_passport(column) }}
  {%- endset -%}
  case
    when {{ norm }} is not null
      then concat(
        substring({{ norm }}, 1, 2),
        ' ****',
        substring({{ norm }}, 8, 3)
      )
    else null
  end
{%- endmacro %}
