{#
    O'zbekistondagi mahalliy to'lov tizimlarini aniqlaydi.

    detect_payment_system:
      Kiruvchi ustun: to'lov tizimining nomi (source system nomi).
      Chiqish: kichik harfda standart nom.

      Qo'llab-quvvatlanadigan tizimlar:
        'click'         — CLICK (Click LLC)
        'payme'         — Payme (PayMe LLC)
        'apelsin'       — Apelsin (Hamkorbank)
        'uzum'          — Uzum Bank (Hamkorbank raqamli mahsuloti)
        'paynet'        — Paynet
        'bank_transfer' — Bank o'tkazmasi (SWIFT/IBAN)
        'cash'          — Naqd pul
        'unknown'       — Boshqa yoki null

    DIQQAT:
      Bu macro 'source_system' yoki 'payment_channel' kabi ANIQ
      nomlangan ustunlar bilan ishlaydi. Tranzaksiya ID'sini parse
      qilmaydi — chunki CLICK, Payme va boshqalarning ID formatlari
      rasmiy hujjatlarda keltirilmagan.

      Misol:
        source_system = 'CLICK'    → 'click'
        source_system = 'PayMe'    → 'payme'
        source_system = 'apelsin'  → 'apelsin'
        source_system = null       → 'unknown'
        source_system = 'cash'     → 'cash'
#}


{% macro detect_payment_system(column) -%}
  {%- set v -%}
    lower(trim({{ column }}))
  {%- endset -%}
  case
    when {{ v }} in ('click', 'click uz', 'click.uz')
      then 'click'
    when {{ v }} in ('payme', 'pay me', 'payme.uz')
      then 'payme'
    when {{ v }} in ('apelsin', 'apelsin.uz')
      then 'apelsin'
    when {{ v }} in ('uzum', 'uzum bank', 'uzumbank', 'uzum.uz')
      then 'uzum'
    when {{ v }} in ('paynet', 'paynet.uz')
      then 'paynet'
    when {{ v }} in ('bank_transfer', 'bank transfer', 'bank o''tkazma',
                     'wire transfer', 'swift', 'naqdsiz')
      then 'bank_transfer'
    when {{ v }} in ('cash', 'naqd', 'naqd pul')
      then 'cash'
    when {{ column }} is null
      then 'unknown'
    else 'unknown'
  end
{%- endmacro %}
