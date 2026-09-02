{#
    O'zbekiston ish kunlari va milliy bayramlarini aniqlash.

    is_uz_holiday:
      Sana O'zbekiston rasmiy bayrami ekanligini tekshiradi.
      Foydalanish: {{ uz_utils.is_uz_holiday('payment_date') }}

    is_working_day:
      Shanba (6) va Yakshanba (7) dam olish kunlari.
      Milliy bayramlar ham ish kuni EMAS.
      Foydalanish: {{ uz_utils.is_working_day('order_date') }}

    ─────────────────────────────────────────────────────────────────────
    is_annual_recurring USTUNI ENDI HAQIQATAN ISHLATILADI
    ─────────────────────────────────────────────────────────────────────
    v0.2'da uz_holidays seed'ida `is_annual_recurring` ustuni bor edi,
    lekin uni HECH BIR macro o'qimasdi. Seed faqat 2024–2026 yillarni
    qamragani uchun natija quyidagicha bo'lardi:

        is_uz_holiday(date '2027-01-01')  →  false   ❌ (Yangi yil!)
        is_working_day(date '2027-01-01') →  true    ❌

    Bu "jimgina noto'g'ri" (silently wrong) xatolik — hech qanday
    ogohlantirish bermaydi, lekin hisobotlarni buzadi.

    v0.3'dan boshlab:
      • is_annual_recurring = true  → oy va kun bo'yicha solishtiriladi,
                                      ya'ni HAR QANDAY yilda ishlaydi.
      • is_annual_recurring = false → aynan o'sha sana bo'yicha
                                      solishtiriladi (masalan, hukumat
                                      qarori bilan ko'chirilgan kunlar
                                      yoki sanasi o'zgaruvchan diniy
                                      bayramlar — Ramazon/Qurbon hayiti).

    ─────────────────────────────────────────────────────────────────────
    HALI QAMRAB OLINMAGAN (bilib turib qoldirilgan)
    ─────────────────────────────────────────────────────────────────────
      • Mehnat kodeksiga ko'ra bayram dam olish kuniga to'g'ri kelsa,
        keyingi ish kuni dam olish kuniga o'tadi.
      • Hukumat har yili ish kunlarini ko'chirish (dam olish kunlarini
        birlashtirish) haqida alohida qaror chiqaradi.
      Ikkalasi ham to'liq "business day" kalendarini talab qiladi —
      alohida issue sifatida ko'rib chiqilsin.

    DIQQAT (arxitektura):
      Bu macro'lar endi correlated subquery emas, compile-time'da
      yaratilgan inline literal ifoda qaytaradi — sabablari uchun
      macros/cross_db/_seed.sql'ga qarang. Modeldan oldin `dbt seed`
      (yoki `dbt build`) ishga tushirilgan bo'lishi shart.
#}


{% macro is_uz_holiday(column) -%}
  {%- set rows = uz_utils.uz_seed_rows(
        'uz_holidays', ['holiday_date', 'is_annual_recurring']) -%}

  {%- set exact = [] -%}
  {%- set recurring = [] -%}
  {%- for row in rows -%}
    {#- Sanani ombor turidan qat'i nazar 'YYYY-MM-DD' ga keltiramiz -#}
    {%- set d = (row[0] | string)[:10] -%}
    {%- set is_rec = (row[1] | string | lower) in ['true', 't', '1', 'yes'] -%}
    {%- if is_rec -%}
      {#- (oy, kun) juftligi — takrorlanishini oldini olamiz -#}
      {%- set md = d[5:7] ~ '-' ~ d[8:10] -%}
      {%- if md not in recurring -%}{% do recurring.append(md) %}{%- endif -%}
    {%- else -%}
      {%- if d not in exact -%}{% do exact.append(d) %}{%- endif -%}
    {%- endif -%}
  {%- endfor -%}

  {%- set as_date = 'cast(' ~ column ~ ' as date)' -%}
  {%- set clauses = [] -%}

  {%- if exact | length > 0 -%}
    {%- set literals = [] -%}
    {%- for d in exact | sort -%}{% do literals.append("date '" ~ d ~ "'") %}{%- endfor -%}
    {% do clauses.append(as_date ~ ' in (' ~ literals | join(', ') ~ ')') %}
  {%- endif -%}

  {%- if recurring | length > 0 -%}
    {%- set md_clauses = [] -%}
    {%- for md in recurring | sort -%}
      {% do md_clauses.append(
           '(extract(month from ' ~ as_date ~ ') = ' ~ md[0:2] | int
           ~ ' and extract(day from ' ~ as_date ~ ') = ' ~ md[3:5] | int ~ ')') %}
    {%- endfor -%}
    {% do clauses.append('(' ~ md_clauses | join('\n      or ') ~ ')') %}
  {%- endif -%}

  {%- if clauses | length == 0 -%}
    {#- Parse bosqichi yoki bo'sh seed: sintaktik jihatdan to'g'ri "false" -#}
    (1 = 0)
  {%- else -%}
  (
    {{ clauses | join('\n    or ') }}
  )
  {%- endif -%}
{%- endmacro %}


{% macro is_working_day(column) -%}
  (
    {{ uz_utils.uz_dayofweek('cast(' ~ column ~ ' as date)') }} <= 5
    and not {{ uz_utils.is_uz_holiday(column) }}
  )
{%- endmacro %}
