{#
    Seed'lardan COMPILE-TIME'da (SQL yaratilayotgan paytda) qiymat o'qish.

    NEGA BU KERAK:
      Avvalgi versiyada seed'ga murojaat qiluvchi macro'lar
      (mfo_to_bank_name, is_uz_holiday, ...) har bir QATOR uchun
      correlated subquery hosil qilar edi:

          (select bank_name_uz from uz_banks where mfo_code = t.mfo limit 1)

      Bu yondashuvning ikkita jiddiy muammosi bor:

      1. PORTATIVLIK. Spark/Databricks correlated scalar subquery'ni
         faqat agregat bilan qabul qiladi ('limit 1' bilan emas), va
         SELECT ro'yxatida IN-subquery'ni umuman qo'llab-quvvatlamaydi.
         Redshift esa correlated subquery ichida LIMIT'ni rad etadi.
         Ya'ni README'da va'da qilingan omborlarning yarmida ishlamaydi.

      2. NARX. Milliard qatorli fakt jadvalida har bir qator uchun
         qidiruv — sekin va qimmat.

      YECHIM: seed kichik (17 bank, 24 bayram) — uni compile paytida
      o'qib, natijani INLINE literal CASE / IN ifodasiga aylantiramiz.
      Natija: barcha omborlarda ishlaydi va qo'shimcha JOIN talab qilmaydi.

      Bu dbt_utils.get_column_values ishlatadigan standart pattern.

    DIQQAT:
      - Seed jadvali ombor ichida MAVJUD bo'lishi shart. Ya'ni modeldan
        oldin `dbt seed` ishga tushirilgan bo'lsin (yoki `dbt build`
        ishlating — u seed'larni avtomatik oldin quradi).
      - Seed o'zgarsa, unga bog'liq modellar QAYTA compile qilinishi
        kerak (`dbt run` yetarli) — chunki qiymatlar SQL ichiga
        "muzlatib" qo'yilgan.
#}

{% macro uz_seed_rows(seed_name, columns) -%}
  {#-
      Seed'dan ustunlarni compile-time'da o'qiydi va qatorlar ro'yxatini
      qaytaradi. Parse bosqichida (execute == false) bo'sh ro'yxat
      qaytaradi — chaqiruvchi macro bunga tayyor bo'lishi kerak.

      MUHIM: ref() `if execute` dan TASHQARIDA chaqiriladi, aks holda
      dbt parse bosqichida bog'liqlikni (dependency) ro'yxatga olmaydi
      va seed modeldan oldin qurilmaydi.
  -#}
  {%- set relation = ref('uz_utils', seed_name) -%}
  {%- set query -%}
    select {{ columns | join(', ') }}
    from {{ relation }}
  {%- endset -%}

  {%- if execute -%}
    {{ return(run_query(query).rows) }}
  {%- else -%}
    {{ return([]) }}
  {%- endif -%}
{%- endmacro %}


{% macro uz_quote_literal(value) -%}
  {#- SQL matn literali: ichidagi apostrof ikkilantiriladi ('' — standart SQL).
      Masalan "O'zbekiston Milliy banki" → 'O''zbekiston Milliy banki' -#}
  {{- "'" ~ (value | string | replace("'", "''")) ~ "'" -}}
{%- endmacro %}
