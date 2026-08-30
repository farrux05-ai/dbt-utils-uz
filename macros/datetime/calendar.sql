{#
    O'zbekiston ish kunlari va milliy bayramlarini aniqlash.

    is_uz_holiday:
      uz_holidays seed'idagi sanalar bilan solishtiradi.
      Foydalanish: {{ uz_utils.is_uz_holiday('payment_date') }}

    is_working_day:
      Shanba (6) va Yakshanba (7) dam olish kunlari.
      Milliy bayramlar ham ish kuni EMAS.
      Foydalanish: {{ uz_utils.is_working_day('order_date') }}

    DIQQAT:
      - Qo'shimcha dam olish kunlari (hukumat qarorlari bilan belgilanadigan
        ko'chirma/qo'shilgan ish kunlari) bu seed'da YO'Q, chunki ular
        har yili alohida e'lon qilinadi. Agar kerak bo'lsa, uz_holidays.csv'ga
        qo'lda qo'shish mumkin (is_annual_recurring = false bilan).
      - Haftalik dam olish kuni O'zbekistonda Shanba+Yakshanba (5-kunlik ish haftasi).
        Ba'zi tashkilotlarda 6-kunlik ish haftasi bo'lishi mumkin — bu holatda
        uz_dayofweek() dan foydalanib custom mantiq yozing.
#}


{% macro is_uz_holiday(column) -%}
  cast({{ column }} as date) in (
    select holiday_date
    from {{ ref('uz_utils', 'uz_holidays') }}
  )
{%- endmacro %}


{% macro is_working_day(column) -%}
  (
    {{ uz_utils.uz_dayofweek('cast(' ~ column ~ ' as date)') }} <= 5
    and not (
      cast({{ column }} as date) in (
        select holiday_date
        from {{ ref('uz_utils', 'uz_holidays') }}
      )
    )
  )
{%- endmacro %}
