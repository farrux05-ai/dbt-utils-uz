{#
    UZ bank kartalari tarmog'ini BIN (birinchi raqamlar) bo'yicha aniqlaydi.

    Diapazonlar:
      8600  -> UzCard
      9860  -> Humo
      4     -> Visa
      51-55 -> Mastercard
      62    -> UnionPay

    DIQQAT: 8600 / 9860 diapazonlari ikkita mustaqil manbadan (BIN
    reestrlari) tasdiqlangan, lekin har ikkala tizim ham kengayishi
    mumkin. Fintech-darajadagi qaror qabul qilishdan oldin real karta
    namunalari bilan tekshirib chiqish tavsiya etiladi.
#}

{% macro detect_card_network(column) -%}
  {%- set digits -%}
    {{ uz_utils.uz_regexp_replace(column, '[^0-9]', '') }}
  {%- endset -%}
  case
    when substring({{ digits }}, 1, 4) = '8600' then 'uzcard'
    when substring({{ digits }}, 1, 4) = '9860' then 'humo'
    when substring({{ digits }}, 1, 1) = '4' then 'visa'
    when substring({{ digits }}, 1, 2) in ('51','52','53','54','55') then 'mastercard'
    when substring({{ digits }}, 1, 2) = '62' then 'unionpay'
    else 'unknown'
  end
{%- endmacro %}


{% macro mask_card_number(column) -%}
  {#
      PII himoyasi uchun: birinchi 4 va oxirgi 4 xonadan boshqasini
      yashiradi. Masalan: '8600123456781234' → '8600 **** **** 1234'

      v0.3'da tuzatilgan uchta xatolik:

      1. AJRATGICHLAR. Avval xom ustun to'g'ridan-to'g'ri kesilardi.
         '8600 1234 5678 1234' kabi formatlangan raqamda
         substring(col, length(col)-3, 4) noto'g'ri belgilarni olardi.
         Endi detect_card_network kabi avval faqat raqamlar ajratiladi.

      2. UZUNLIK NAZORATI. Qisqa qiymatda (masalan '1234') birinchi 4 va
         oxirgi 4 belgi USTMA-UST tushadi va funksiya raqamni
         MASKALAMASDAN qaytarardi — ya'ni PII sizib chiqardi.
         Endi kamida 12 xona talab qilinadi.

      3. FAIL-CLOSED. Format kutilganidek bo'lmasa null qaytariladi,
         xom qiymat EMAS. Maskalash funksiyasi hech qachon
         maskalanmagan qiymatni o'tkazmasligi kerak.
  #}
  {%- set digits -%}
    {{ uz_utils.uz_regexp_replace(column, '[^0-9]', '') }}
  {%- endset -%}
  case
    when {{ uz_utils.uz_regexp_like(digits, '^[0-9]{12,19}$') }}
      then concat(
        substring({{ digits }}, 1, 4),
        ' **** **** ',
        substring({{ digits }}, length({{ digits }}) - 3, 4)
      )
    else null
  end
{%- endmacro %}
