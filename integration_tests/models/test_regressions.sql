{{ config(materialized='table') }}

/*
    v0.3 REGRESSIYA TESTLARI.

    Har bir case shu paketda topilgan HAQIQIY xatolikni qamrab oladi.
    Bu testlar tuzatishlardan OLDIN yiqilishi kerak edi.

    0 qator = barcha testlar o'tdi ✅

    DIQQAT (test uslubi):
      Solishtirish `is distinct from` orqali qilinadi, `!=` orqali EMAS.
      `null != 'x'` → null, ya'ni `where` filtri null holatni JIMGINA
      o'tkazib yuboradi va test hech narsa tekshirmagan bo'ladi.
      Avvalgi testlardagi barcha null case'lar aynan shu sababli
      bekorga (vacuously) "o'tayotgan" edi.
*/

with cases as (

    -------------------------------------------------------------------
    -- 1. mask_phone operator kodini SAQLASHI kerak.
    --    Xatolik: '+99890' hardcode qilingan edi — Beeline/Ucell
    --    raqamlari ham '90' (Uzmobile) bo'lib ko'rinardi.
    -------------------------------------------------------------------
    select 'mask_phone: uzmobile 90' as case_name,
           {{ uz_utils.mask_phone("'+998901234567'") }} as actual,
           '+99890****567'                             as expected
    union all
    select 'mask_phone: ucell 93 kodi saqlanadi',
           {{ uz_utils.mask_phone("'+998931234567'") }}, '+99893****567'
    union all
    select 'mask_phone: beeline 91 kodi saqlanadi',
           {{ uz_utils.mask_phone("'+998911234567'") }}, '+99891****567'

    -------------------------------------------------------------------
    -- 2. Maskalash fail-closed bo'lishi kerak: yaroqsiz format uchun
    --    XOM qiymat emas, null. Xatolik: mask_pinfl `else {{ column }}`
    --    qilib xom PINFL'ni maskalamasdan qaytarardi (PII sizishi).
    -------------------------------------------------------------------
    union all
    select 'mask_pinfl: to''g''ri PINFL',
           {{ uz_utils.mask_pinfl("'31234560012345'") }}, '3************5'
    union all
    select 'mask_pinfl: yaroqsiz → null (xom qiymat EMAS)',
           {{ uz_utils.mask_pinfl("'not-a-pinfl'") }}, null
    union all
    select 'mask_passport: oxirgi 3 xona (4 emas)',
           {{ uz_utils.mask_passport("'ab1234567'") }}, 'AB ****567'

    -------------------------------------------------------------------
    -- 3. mask_card_number: ajratgichli va qisqa qiymatlar.
    --    Xatolik: ajratgichlar tozalanmasdi va uzunlik tekshirilmasdi,
    --    natijada qisqa qiymat MASKALANMAGAN holda qaytishi mumkin edi.
    -------------------------------------------------------------------
    union all
    select 'mask_card: ajratgichsiz',
           {{ uz_utils.mask_card_number("'8600123456781234'") }}, '8600 **** **** 1234'
    union all
    select 'mask_card: bo''sh joyli format',
           {{ uz_utils.mask_card_number("'8600 1234 5678 1234'") }}, '8600 **** **** 1234'
    union all
    select 'mask_card: qisqa qiymat → null (sizib chiqmaydi)',
           {{ uz_utils.mask_card_number("'1234'") }}, null

    -------------------------------------------------------------------
    -- 4. format_uzs. Xatolik: macro Jinja'da PARSE BO'LMAS edi
    --    (Jinja ifodasi ichida yana Jinja ifodasi), ya'ni butun
    --    paket parse bo'lmasdan yiqilardi.
    --    Ikkinchi xatolik: regex lookahead — BigQuery/Snowflake/Redshift
    --    uni qo'llab-quvvatlamaydi.
    -------------------------------------------------------------------
    union all
    select 'format_uzs: million',
           {{ uz_utils.format_uzs('1250000') }}, '1 250 000'
    union all
    select 'format_uzs: ajratgichsiz',
           {{ uz_utils.format_uzs('999') }}, '999'
    union all
    select 'format_uzs: nol',
           {{ uz_utils.format_uzs('0') }}, '0'
    union all
    select 'format_uzs: milliard',
           {{ uz_utils.format_uzs('1000000000') }}, '1 000 000 000'
    union all
    select 'format_uzs: manfiy son',
           {{ uz_utils.format_uzs('-1250000') }}, '-1 250 000'

    -------------------------------------------------------------------
    -- 5. is_valid_* null uchun FALSE qaytarishi kerak, null emas.
    --    Xatolik: null qaytarardi, shu sababli `where not is_valid_x(c)`
    --    filtri iflos qatorlarni jimgina tashlab ketardi.
    -------------------------------------------------------------------
    union all
    select 'is_valid_pinfl(null) = false',
           cast({{ uz_utils.is_valid_pinfl('cast(null as varchar)') }} as varchar), 'false'
    union all
    select 'is_valid_stir(null) = false',
           cast({{ uz_utils.is_valid_stir('cast(null as varchar)') }} as varchar), 'false'
    union all
    select 'is_valid_mfo(null) = false',
           cast({{ uz_utils.is_valid_mfo('cast(null as varchar)') }} as varchar), 'false'
    union all
    select 'is_valid_passport(null) = false',
           cast({{ uz_utils.is_valid_passport('cast(null as varchar)') }} as varchar), 'false'

    -------------------------------------------------------------------
    -- 6. pinfl_birth_date iflos ma'lumotda YIQILMASLIGI kerak.
    --    Xatolik: himoyalanmagan cast(... as date) — manbadagi bitta
    --    buzilgan PINFL butun modelni to'xtatardi.
    -------------------------------------------------------------------
    union all
    select 'pinfl_birth_date: to''g''ri',
           cast({{ uz_utils.pinfl_birth_date("'31210630123459'") }} as varchar), '1963-10-12'
    union all
    select 'pinfl_birth_date: oy 99 → null (xato bermaydi)',
           cast({{ uz_utils.pinfl_birth_date("'31299630123459'") }} as varchar), null
    union all
    select 'pinfl_birth_date: butunlay axlat → null',
           cast({{ uz_utils.pinfl_birth_date("'xxxxxxxxxxxxxx'") }} as varchar), null
    union all
    select 'pinfl_gender: axlat → null',
           {{ uz_utils.pinfl_gender("'xxxxxxxxxxxxxx'") }}, null

    -------------------------------------------------------------------
    -- 7. Takrorlanuvchi bayramlar seed diapazonidan TASHQARIDA ham
    --    ishlashi kerak. Xatolik: is_annual_recurring ustuni hech qayerda
    --    o'qilmasdi, seed esa faqat 2024–2026 — ya'ni 2027-yil
    --    1-yanvar oddiy ish kuni bo'lib ko'rinardi.
    -------------------------------------------------------------------
    union all
    select 'is_uz_holiday: 2027-01-01 (seed diapazonidan tashqarida)',
           cast({{ uz_utils.is_uz_holiday("date '2027-01-01'") }} as varchar), 'true'
    union all
    select 'is_uz_holiday: 2030-09-01 Mustaqillik kuni',
           cast({{ uz_utils.is_uz_holiday("date '2030-09-01'") }} as varchar), 'true'
    union all
    select 'is_working_day: 2027-01-01 ish kuni EMAS',
           cast({{ uz_utils.is_working_day("date '2027-01-01'") }} as varchar), 'false'
    union all
    select 'is_uz_holiday: oddiy chorshanba',
           cast({{ uz_utils.is_uz_holiday("date '2027-01-13'") }} as varchar), 'false'
    union all
    select 'is_working_day: oddiy chorshanba',
           cast({{ uz_utils.is_working_day("date '2027-01-13'") }} as varchar), 'true'
    union all
    select 'is_working_day: shanba',
           cast({{ uz_utils.is_working_day("date '2027-01-16'") }} as varchar), 'false'

    -------------------------------------------------------------------
    -- 8. Seed qidiruvi (endi compile-time CASE).
    --    Bank nomidagi apostrof to'g'ri escape qilinishi ham tekshiriladi.
    -------------------------------------------------------------------
    union all
    select 'mfo_to_bank_name: NBU (apostrofli nom)',
           {{ uz_utils.mfo_to_bank_name("'00873'") }}, 'O''zbekiston Milliy banki'
    union all
    select 'mfo_to_bank_short: NBU',
           {{ uz_utils.mfo_to_bank_short("'00873'") }}, 'NBU'
    union all
    select 'mfo_to_bank_name: mavjud emas → null',
           {{ uz_utils.mfo_to_bank_name("'99999'") }}, null

    -------------------------------------------------------------------
    -- 9. SQL matn literallari. Xatolik: region.sql QO'SH TIRNOQ
    --    ishlatgan ("farg'ona") — bu SQL'da IDENTIFIKATOR, matn emas;
    --    district.sql esa '\'' backslash-escape ishlatgan — standart
    --    SQL'da bunday escape yo'q. Ikkalasi ham sintaksis xatosi berardi.
    -------------------------------------------------------------------
    union all
    select 'region: Farg''ona (qo''sh tirnoq xatosi)',
           {{ uz_utils.normalize_region_name("'Farg''ona'") }}, 'UZ-FA'
    union all
    select 'region: Qoraqalpog''iston',
           {{ uz_utils.normalize_region_name("'Qoraqalpog''iston'") }}, 'UZ-QR'
    union all
    select 'district: Qo''qon (backslash escape xatosi)',
           {{ uz_utils.normalize_district_name("'Qo''qon'") }}, 'Qo''qon tumani'
    union all
    select 'district: Mirzo Ulug''bek',
           {{ uz_utils.normalize_district_name("'mirzo ulugbek'") }}, 'Mirzo Ulug''bek tumani'
    union all
    select 'payment_system: bank o''tkazma (backslash escape xatosi)',
           {{ uz_utils.detect_payment_system("'bank o''tkazma'") }}, 'bank_transfer'

    -------------------------------------------------------------------
    -- 10. Kirill transliteratsiyasidagi imlo xatolari.
    -------------------------------------------------------------------
    union all
    select 'district: чуст (avval "чует" deb yozilgan edi)',
           {{ uz_utils.normalize_district_name("'чуст'") }}, 'Chust tumani'
    union all
    select 'district: денов (avval "дэнов" deb yozilgan edi)',
           {{ uz_utils.normalize_district_name("'денов'") }}, 'Denov tumani'

    -------------------------------------------------------------------
    -- 11. Ifoda qaytaruvchi macro'lar QAVS ichida bo'lishi kerak, aks
    --     holda chaqiruvchi tomonda operator ustuvorligi buziladi.
    --     Xatolik: `is_post_denomination(d) != exp` → sintaksis xatosi.
    -------------------------------------------------------------------
    union all
    select 'is_post_denomination: kompozitsiya qilinadi',
           cast(({{ uz_utils.is_post_denomination("date '2018-01-01'") }} = true) as varchar), 'true'
    union all
    select 'is_post_denomination: denominatsiyagacha',
           cast({{ uz_utils.is_post_denomination("date '2017-09-30'") }} as varchar), 'false'

)

select case_name, expected, actual
from cases
where actual is distinct from expected
