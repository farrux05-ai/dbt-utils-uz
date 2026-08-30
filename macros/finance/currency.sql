{#
    O'zbekiston so'mi (UZS) bilan ishlash uchun yordamchi macro'lar.

    format_uzs:
      Sonni o'qilishi qulay minglik ajratgichli formatga keltiradi.
      1250000  →  '1 250 000'
      999      →  '999'
      0        →  '0'
      null     →  null

      DIQQAT: Bu macro matn (string) qaytaradi, hisob-kitob uchun emas,
      faqat ko'rsatish (display) uchun mo'ljallangan.

    is_post_denomination:
      O'zbekistonda 2017-yil 1-oktabrda 1:1000 denominatsiya o'tkazildi.
      Sana 2017-10-01 dan keyin bo'lsa — true (yangi so'm).
      Eski bazalarda "5 000 000 so'm" = yangi "5 000 so'm" bo'lishi mumkin.
      Bu macro denominatsiya muammosini flag qilib beradi.

      Foydalanish misoli:
        select
          amount,
          {{ uz_utils.is_post_denomination('transaction_date') }} as is_new_uzs,
          case
            when not {{ uz_utils.is_post_denomination('transaction_date') }}
            then amount / 1000.0  -- eski so'mni yangi so'mga o'tkazish
            else amount
          end as amount_normalized_uzs
        from {{ ref('raw_transactions') }}
#}


{% macro format_uzs(column) -%}
  {#-
      Har 3 ta raqamdan keyin bo'sh joy qo'yish.
      Barcha omborlarda ishlaydigan universal yondashuv:
      sonni matnga aylantirb, regex bilan formatlash.
  -#}
  case
    when {{ column }} is null then null
    else {{ uz_utils.uz_regexp_replace(
      cast(cast({{ column }} as {{ dbt.type_bigint() }}) as {{ dbt.type_string() }}),
      '([0-9])(?=([0-9]{3})+$)',
      '\\1 '
    ) }}
  end
{%- endmacro %}


{% macro is_post_denomination(date_column) -%}
  cast({{ date_column }} as date) >= date '2017-10-01'
{%- endmacro %}
