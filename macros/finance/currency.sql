{#
    O'zbekiston so'mi (UZS) bilan ishlash uchun yordamchi macro'lar.

    format_uzs:
      Sonni o'qilishi qulay minglik ajratgichli formatga keltiradi.
      1250000  →  '1 250 000'
      999      →  '999'
      0        →  '0'
      -1250000 →  '-1 250 000'
      null     →  null

      DIQQAT: Bu macro matn (string) qaytaradi, hisob-kitob uchun emas,
      faqat ko'rsatish (display) uchun mo'ljallangan.

      DIQQAT: Kirish qiymati BIGINT'ga keltiriladi — kasr qismi
      yo'qoladi (1250.7 → '1 251' yoki '1 250', ombor turiga qarab).
      UZS amalda butun son bo'lgani uchun bu maqsadli xatti-harakat.

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


{#-
    Minglik ajratgichlarni qo'yish uchun ishlatiladigan pattern.

    NEGA lookahead ISHLATILMAYDI:
      Avvalgi versiyada '([0-9])(?=([0-9]{3})+$)' lookahead ishlatilgan edi.
      Lookahead'ni faqat PostgreSQL va Spark qo'llab-quvvatlaydi —
      BigQuery (RE2), Snowflake va Redshift regex dvigatellari uni
      TUSHUNMAYDI va xatolik beradi.

      Buning o'rniga chapdan o'ngga bir nechta oddiy o'tish (pass)
      qilinadi. Har bir o'tish oxirgi 3 xonadan oldin bitta bo'sh joy
      qo'yadi; '[0-9]+' bo'sh joydan o'ta olmagani uchun keyingi o'tish
      avtomatik ravishda chapga siljiydi:

        '1250000'  →  '1250 000'  →  '1 250 000'  →  (o'zgarishsiz)

      7 ta o'tish 21 xonagacha bo'lgan sonlarni qamrab oladi — BIGINT
      maksimumi (19 xona) dan ortiq, ya'ni yetarli.
-#}
{% macro format_uzs(column) -%}
  {%- set as_text -%}
    cast(cast({{ column }} as {{ dbt.type_bigint() }}) as {{ dbt.type_string() }})
  {%- endset -%}

  {%- set ns = namespace(expr = as_text) -%}
  {%- for _ in range(7) -%}
    {%- set ns.expr = uz_utils.uz_regexp_replace(ns.expr, '^(-?[0-9]+)([0-9]{3})', '\\1 \\2') -%}
  {%- endfor -%}

  case
    when {{ column }} is null then null
    else {{ ns.expr }}
  end
{%- endmacro %}


{% macro is_post_denomination(date_column) -%}
  {#- Qavs SHART: qavssiz ifoda chaqiruvchi tomonda operator ustuvorligini
      buzadi, masalan `... >= date '2017-10-01' != exp` → sintaksis xatosi. -#}
  (cast({{ date_column }} as date) >= date '2017-10-01')
{%- endmacro %}
