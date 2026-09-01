{#
    O'zbekiston QQS (NDS / Value Added Tax) hisoblash macro'lari.

    O'zbekistonda QQS stavkalari:
      - 2023-yil 1-yanvardan boshlab: 12% (standart stavka)
      - 2019–2022-yillar: 15%
      - 0% stavka (eksport va maxsus xizmatlar)

    calculate_vat_from_total:
      QQS kiritilgan (brutto) summadan QQS miqdorini ajratib oladi.
      Formula: total_amount * vat_rate / (100 + vat_rate)
      Misol (12% stavkada 112 000 so'm uchun):
        112 000 * 12 / 112 = 12 000 so'm QQS

    calculate_net_amount:
      QQS kiritilgan (brutto) summadan QQSsiz sof (net) summani ajratadi.
      Formula: total_amount * 100 / (100 + vat_rate)
      Misol (12% stavkada 112 000 so'm uchun):
        112 000 * 100 / 112 = 100 000 so'm sof summa

    add_vat:
      QQSsiz (net) summaning ustiga QQS qo'shib umumiy summani hisoblaydi.
      Formula: net_amount * (1 + vat_rate / 100)
      Misol (12% stavkada 100 000 so'm uchun):
        100 000 * 1.12 = 112 000 so'm
#}


{% macro calculate_vat_from_total(total_amount, vat_rate=12) -%}
  (
    cast({{ total_amount }} as {{ dbt.type_numeric() }}) * {{ vat_rate }}
    / (100.0 + {{ vat_rate }})
  )
{%- endmacro %}


{% macro calculate_net_amount(total_amount, vat_rate=12) -%}
  (
    cast({{ total_amount }} as {{ dbt.type_numeric() }}) * 100.0
    / (100.0 + {{ vat_rate }})
  )
{%- endmacro %}


{% macro add_vat(net_amount, vat_rate=12) -%}
  (
    cast({{ net_amount }} as {{ dbt.type_numeric() }})
    * (1.0 + ({{ vat_rate }} / 100.0))
  )
{%- endmacro %}
