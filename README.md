# uz_utils

[![dbt](https://img.shields.io/badge/dbt-%3E%3D1.6-orange)](https://getdbt.com)
[![license](https://img.shields.io/badge/license-MIT-blue)](LICENSE)

> **O'zbekiston uchun dbt macro'lar kutubxonasi**

O'zbekiston bozorida ishlaydigan har qanday data jamoa bir xil muammolarga duch keladi:

- PINFL/JSHSHIR ni to'g'ri tahlil qilish
- STIR (INN) formatini tekshirish
- `+998901234567`, `998-90-123-45-67`, `090 123 45 67` — bularni bir xilga keltirish
- UzCard / Humo / Visa kartalarni farqlash
- `"Toshkent"`, `"Tashkent city"`, `"г.Ташкент"` — bularning barchasini bir ISO kodga tushirish

Har bir jamoa bu ishni o'z loyihasida qayta yozadi. **`uz_utils`** — shu takroriy ishni bir marta yaxshi qilib, hammaga ochiq qoldirish uchun tuzilgan paket.

---

## O'rnatish

```yaml
# packages.yml
packages:
  - git: "https://github.com/farrux05-ai/dbt-utils-uz.git"
    revision: main
```

Keyin:

```bash
dbt deps
```

---

## Macro'lar

### 🪪 Identifikatorlar

| Macro | Nima qiladi |
|---|---|
| `uz_utils.is_valid_pinfl(column)` | PINFL formatini tekshiradi (14 raqam + 1–6 birinchi xona) |
| `uz_utils.pinfl_gender(column)` | PINFL'dan jinsni ajratadi → `erkak` yoki `ayol` |
| `uz_utils.pinfl_birth_date(column)` | PINFL'dan tug'ilgan sanani ajratadi → `DATE` turi |
| `uz_utils.pinfl_region_code(column)` | PINFL'dan hudud kodini ajratadi (8–10-xonalar) |
| `uz_utils.is_valid_stir(column)` | STIR/INN formatini tekshiradi (9 raqam) |
| `uz_utils.is_valid_passport(column)` | Passport formatini tekshiradi: `AB 1234567` standart ko'rinish |
| `uz_utils.normalize_passport(column)` | `'ab1234567'`, `'AB-1234567'` → `'AB 1234567'` |
| `uz_utils.is_valid_mfo(column)` | Bank MFO kodini tekshiradi (5 xonali raqam) |
| `uz_utils.mfo_to_bank_name(column)` | MFO kodi → bank nomi (`uz_banks` seed orqali) |
| `uz_utils.mfo_to_bank_short(column)` | MFO kodi → bank qisqa nomi |

**PINFL tuzilishi:**

```
Pozitsiya:  1       2–7       8–10    11–13   14
            │       │         │       │       │
            asr+jins tug'ilgan hudud  tartib  nazorat
                     sana(ddmm yy)   kodi    raqami
```

| 1-pozitsiya | Ma'nosi |
|---|---|
| 1 | 1800–1899, erkak |
| 2 | 1800–1899, ayol  |
| 3 | 1900–1999, erkak |
| 4 | 1900–1999, ayol  |
| 5 | 2000–2099, erkak |
| 6 | 2000–2099, ayol  |

---

### 📞 Telefon raqamlari

| Macro | Nima qiladi |
|---|---|
| `uz_utils.normalize_uz_phone(column)` | Har qanday formatni `+998XXXXXXXXX` ga keltiradi |
| `uz_utils.uz_phone_operator(column)` | Operator kodini ajratadi (2 xona, masalan `90`) |

**Qabul qiladigan formatlar:**

```
998901234567      →  +998901234567
+998 90 123-45-67 →  +998901234567
0901234567        →  +998901234567
901234567         →  +998901234567
```

---

### 💳 To'lov tizimlari

| Macro | Nima qiladi |
|---|---|
| `uz_utils.detect_card_network(column)` | Karta tizimini BIN bo'yicha aniqlaydi (`uzcard`/`humo`/`visa`/...) |
| `uz_utils.mask_card_number(column)` | Karta raqamini PII uchun maskalaydi: `8600 **** **** 1234` |
| `uz_utils.detect_payment_system(column)` | To'lov kanalini aniqlaydi: `click`/`payme`/`apelsin`/`uzum`/`bank_transfer`/`cash` |

**`detect_payment_system` misollari:**
```
'CLICK'        →  'click'
'PayMe'        →  'payme'
'apelsin'      →  'apelsin'
'Uzum Bank'    →  'uzum'
'naqd'         →  'cash'
null           →  'unknown'
```

---

### 🗺️ Hudud (geo)

| Macro / Seed | Nima qiladi |
|---|---|
| `uz_utils.normalize_region_name(column)` | Viloyat nomini ISO 3166-2:UZ kodiga keltiradi |
| `uz_utils.normalize_district_name(column)` | Tuman nomini standart o'zbek nomi ko'rinishiga keltiradi |
| `seed: uz_regions` | 14 ta viloyat: ISO kod, uz/en/ru nomi, markaz shahri |
| `seed: uz_districts` | 160+ tuman: kod, nomi, viloyat ISO kodi, markaz |

**`normalize_region_name` misollari:**
```
'Toshkent shahri'  →  'UZ-TK'
'Tashkent city'    →  'UZ-TK'
'Andijon'          →  'UZ-AN'
"Farg'ona"         →  'UZ-FA'
```

**`normalize_district_name` misollari:**
```
'Yunusobod'       →  'Yunusobod tumani'
'Yunusabad'       →  'Yunusobod tumani'
'Chilonzor r.'    →  'Chilonzor tumani'
'noma\'lum joy'   →  null
```

---

### 📅 Sana va ish kunlari

| Macro / Seed | Nima qiladi |
|---|---|
| `uz_utils.is_uz_holiday(column)` | Sana milliy bayrammi? (`uz_holidays` seed orqali) |
| `uz_utils.is_working_day(column)` | Ish kunmi? (Shanba/Yakshanba va bayramlar — ish kuni emas) |
| `seed: uz_holidays` | 2024–2026 yillardagi rasmiy milliy bayramlar |

**Misol:**
```
'2024-03-21' (Navro'z)   →  is_uz_holiday: true   is_working_day: false
'2024-03-23' (Shanba)    →  is_uz_holiday: false   is_working_day: false
'2024-03-18' (Dushanba)  →  is_uz_holiday: false   is_working_day: true
```

---

### 💰 Moliya (Finance)

| Macro | Nima qiladi |
|---|---|
| `uz_utils.format_uzs(column)` | Sonni minglik ajratgichli formatga keltiradi: `1250000` → `'1 250 000'` |
| `uz_utils.is_post_denomination(date_column)` | 2017-10-01 dan keyin (yangi so'm) ekanligini tekshiradi |

---

### 🔒 Maxfiylik (PII / Compliance)

| Macro | Nima qiladi |
|---|---|
| `uz_utils.mask_pinfl(column)` | `'31234560012345'` → `'3************5'` |
| `uz_utils.mask_phone(column)` | `'+998901234567'` → `'+99890****567'` |
| `uz_utils.mask_passport(column)` | `'AB 1234567'` → `'AB ****567'` |

---

### ⚙️ Cross-database (ichki)

`macros/cross_db/` — barcha SQL dialekt farqlari shu papkada yashiriladi.

| Fayl | Nima qiladi |
|---|---|
| `_regexp.sql` | `uz_regexp_like()`, `uz_regexp_replace()` |
| `_datetime.sql` | `uz_dayofweek()` — 1=Du, 7=Ya, barcha omborlarda bir xil |

**Qo'llab-quvvatlanadigan warehouse'lar:**

| Warehouse | Holat |
|---|---|
| PostgreSQL | ✅ Sinovdan o'tgan |
| Redshift | ✅ Sinovdan o'tgan |
| BigQuery | ✅ Sinovdan o'tgan |
| Snowflake | ✅ Default |
| Spark | ✅ Sinovdan o'tgan |
| Databricks | ✅ Sinovdan o'tgan |
| ClickHouse | ⚠️ Mantiqiy jihatdan to'g'ri, real instansiyada sinovdan o'tmagan |

---

## Foydalanish misoli

```sql
-- models/staging/stg_customers_enriched.sql
select
    customer_id,

    -- Identifikatorlar
    {{ uz_utils.is_valid_pinfl('customer_pinfl') }}       as pinfl_is_valid,
    {{ uz_utils.pinfl_gender('customer_pinfl') }}         as gender,
    {{ uz_utils.pinfl_birth_date('customer_pinfl') }}     as birth_date,
    {{ uz_utils.is_valid_passport('passport_raw') }}      as passport_is_valid,
    {{ uz_utils.normalize_passport('passport_raw') }}     as passport_clean,
    {{ uz_utils.is_valid_stir('company_stir') }}          as stir_is_valid,
    {{ uz_utils.mfo_to_bank_name('bank_mfo') }}           as bank_name,

    -- Telefon
    {{ uz_utils.normalize_uz_phone('raw_phone') }}        as phone_normalized,

    -- To'lov
    {{ uz_utils.detect_card_network('card_number') }}     as card_network,
    {{ uz_utils.detect_payment_system('payment_source') }}as payment_system,

    -- Hudud
    {{ uz_utils.normalize_region_name('region_raw') }}   as region_iso,
    {{ uz_utils.normalize_district_name('district_raw') }}as district_name,

    -- Sana
    {{ uz_utils.is_working_day('order_date') }}           as is_working_day,
    {{ uz_utils.is_uz_holiday('order_date') }}            as is_holiday,

    -- Moliya
    {{ uz_utils.format_uzs('amount') }}                   as amount_formatted,
    {{ uz_utils.is_post_denomination('transaction_date') }}as is_new_uzs,

    -- PII maskalash (mart qatlamiga o'tmasin)
    {{ uz_utils.mask_pinfl('customer_pinfl') }}           as pinfl_masked,
    {{ uz_utils.mask_phone('raw_phone') }}                as phone_masked

from {{ ref('raw_customers') }}
```

---

## Rejadagi macro'lar (v0.3+)

Har biri kimningdir kunlik manual ishi. **Sizda ham shunday takroriy ish bo'lsa — PR yuboring.**

### IBAN / bank hisob raqami validatsiyasi
- O'zbekiston bank hisob raqami formati: 20 xonali
- `uz_utils.is_valid_bank_account(column)` macro'si

### OKED faoliyat turi kodi
- `seeds/uz_oked.csv` — faoliyat turlari klassifikatori
- `uz_utils.is_valid_oked(column)` macro'si

### Telefon operator nomi
- `seeds/uz_phone_operators.csv` — operator kodi → nomi (UMS, Beeline, Ucell...)
- Tez-tez o'zgaradi — shuning uchun seed sifatida ajratilgan

### So'm kursi tarixi
- `seeds/uzs_exchange_rates.csv` — USD/EUR kurslar tarixi
- Denominatsiya (2017) bilan birga

---

## Hissa qo'shish (Contribution)

Bu paket O'zbekistondagi data hamjamiyati uchun qurilgan. Agar sizda:
- Takroriy qilinadigan normalizatsiya/validatsiya logic bo'lsa
- Yangi identifikator formati bo'lsa
- Boshqa warehouse uchun regex implementatsiyasi bo'lsa

...iltimos PR yuboring yoki issue oching.

**Yangi macro qo'shish tartibi:**
1. Tegishli `macros/<kategoriya>/` papkasiga `.sql` fayl yarating
2. Faylning boshiga `{# ... #}` blokida maqsad va cheklovlarni yozing
3. `integration_tests/` ga test model qo'shing
4. README'dagi jadvalga qo'shing

---

## Ma'lum cheklovlar (v0.1)

| Cheklov | Sabab |
|---|---|
| STIR nazorat raqami tekshirilmaydi | Rasmiy formula ochiq manbada yo'q |
| PINFL 14-pozitsiya checksum yo'q | Xuddi shu sabab |
| UzCard/Humo BIN diapazoni kengayishi mumkin | BIN reestrlar yangilanadi |
| Telefon operator nomi map qilinmaydi | Ro'yxat tez-tez o'zgaradi |
| ClickHouse real instansiyada sinovdan o'tmagan | Muhit mavjud emas |
| 4 ta ISO kod (`QA, SA, SI, SU`) — Wikipedia'da bevosita tasdiqlanmagan | `seeds/uz_regions.yml`da batafsil |

---

## Test qilish

```bash
cd integration_tests
dbt deps
dbt seed
dbt run
dbt test
```

---

## Litsenziya

MIT — `LICENSE` faylga qarang.
