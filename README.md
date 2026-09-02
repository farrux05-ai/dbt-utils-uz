# 🇺🇿 uz_utils

[![dbt](https://img.shields.io/badge/dbt-%3E%3D1.6-orange.svg)](https://getdbt.com)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/farrux05-ai/dbt-utils-uz/pulls)

> **`uz_utils`** 🇺🇿 — O'zbekiston ma'lumotlar ekotizimi uchun mo'ljallangan dbt macro'lar va ma'lumotnomalar (seeds) to'plami. `dbt_utils` standarti va arxitekturasi asosida qurilgan.

---

## 📌 Nima uchun uz_utils?

O'zbekistonda ma'lumotlar (Data Warehouse) bilan ishlaydigan data-muhandislar va analitiklar doimiy ravishda bir xil takroriy muammolarga duch kelishadi:
- **PINFL / STIR / Passport** va **MFO** kabi identifikatorlarni formatlash va validatsiyadan o'tkazish.
- **Telefon raqamlarini** turli ko'rinishlardan (`+99890...`, `99890...`, `090...`) yagona standartga keltirish.
- **UzCard, Humo, Visa, Mastercard** kartalarini BIN diapazonlari bo'yicha ajratish.
- **Toshkent shahri va viloyatlar**, hamda 160+ **tuman nomlarini** ISO va rasmiy standartlarga moslash.
- **O'zbekiston milliy bayramlari**, haftalik va ish kunlarini aniqlash.
- **PII (shaxsga tegishli maxfiy ma'lumotlar)** ni staging va mart qatlamlarida niqoblash (maskalash).

`uz_utils` loyihasi ushbu kunlik takroriy ishlarni bir joyga jamlab, ochiq manbali standartga aylantirishni maqsad qilgan.

---

## ⚡ Tezkor O'rnatish

Loyihangizdagi `packages.yml` fayliga quyidagi qatorni qo'shing:

```yaml
packages:
  - git: "https://github.com/farrux05-ai/dbt-utils-uz.git"
    revision: main
```

So'ngra terminalda quyidagi buyruqni ishga tushiring:

```bash
dbt deps
```

---

## 🛠️ Kutubxona Tarkibi & Imkoniyatlar

Kutubxona faqat **`macros`**, **`seeds`** va **`integration_tests`** dan tashkil topgan (modellar yo'q).

### 1. 🪪 Shaxs va Korxona Identifikatorlari (`identifiers`)

| Macro | Tavsif | Misol / Natija |
|---|---|---|
| `uz_utils.is_valid_pinfl(col)` | PINFL formatini tekshirish (14 raqam + 1-6 oralig'i) | `true` / `false` |
| `uz_utils.pinfl_gender(col)` | PINFL'dan jinsni aniqlash | `'erkak'` / `'ayol'` |
| `uz_utils.pinfl_birth_date(col)` | PINFL'dan tug'ilgan sanani olish | `DATE '1995-10-25'` |
| `uz_utils.pinfl_region_code(col)` | PINFL'dan hudud kodini ajratib olish | `'001'`, `'002'`... |
| `uz_utils.is_valid_stir(col)` | STIR (INN) formatini tekshirish (9 raqam) | `true` / `false` |
| `uz_utils.is_valid_passport(col)` | Pasport formatini tekshirish (`AA 1234567`) | `true` / `false` |
| `uz_utils.normalize_passport(col)` | Pasport seriya/raqamini standartga keltirish | `'ab1234567'` → `'AB 1234567'` |
| `uz_utils.is_valid_mfo(col)` | Bank MFO kodini tekshirish (5 raqam) | `true` / `false` |
| `uz_utils.mfo_to_bank_name(col)` | MFO kodi bo'yicha bank rasmiy nomini olish | `'00873'` → `'O\'zbekiston Milliy banki'` |
| `uz_utils.mfo_to_bank_short(col)` | MFO kodi bo'yicha bank qisqa nomini olish | `'00873'` → `'NBU'` |

---

### 2. 📞 Telefon Raqamlari (`contact`)

| Macro | Tavsif | Misol / Natija |
|---|---|---|
| `uz_utils.normalize_uz_phone(col)` | Har qanday formatni `+998XXXXXXXXX` ko'rinishiga keltirish | `'901234567'` → `'+998901234567'` |
| `uz_utils.uz_phone_operator(col)` | Telefon raqamidan operator kodini ajratish | `'+998901234567'` → `'90'` |

---

### 3. 💳 To'lovlar va Fintech (`payments`)

| Macro | Tavsif | Misol / Natija |
|---|---|---|
| `uz_utils.detect_card_network(col)` | Karta BIN diapazoni bo'yicha to'lov tizimini aniqlash | `'8600...'` → `'uzcard'`, `'9860...'` → `'humo'` |
| `uz_utils.detect_payment_system(col)` | To'lov kanali/servisini unifikatsiya qilish | `'CLICK'`, `'Click.uz'` → `'click'`, `'PayMe'` → `'payme'` |
| `uz_utils.mask_card_number(col)` | Karta raqamini maskalash | `'8600123456781234'` → `'8600 **** **** 1234'` |

---

### 4. 🗺️ Geografiya va Hududlar (`geo` & `seeds`)

| Macro / Seed | Tavsif | Misol / Natija |
|---|---|---|
| `uz_utils.normalize_region_name(col)` | Viloyat va shahar nomini ISO 3166-2:UZ kodiga moslash | `'Tashkent city'` → `'UZ-TK'`, `'Andijon'` → `'UZ-AN'` |
| `uz_utils.normalize_district_name(col)` | Tuman nomini standart o'zbek imlosiga keltirish | `'Yunusabad'` → `'Yunusobod tumani'` |
| `seed: uz_regions` | O'zbekistonning 14 ma'muriy hududi (ISO kodi, Uz/En/Ru nomi, markazi) | Reference seed |
| `seed: uz_districts` | 160+ tuman va shaharlar ma'lumotnomasi (viloyat ISO kodi bilan) | Reference seed |

---

### 5. 📅 Sana va Ish Kunlari (`datetime` & `seeds`)

| Macro / Seed | Tavsif | Misol / Natija |
|---|---|---|
| `uz_utils.is_uz_holiday(col)` | Sana O'zbekiston rasmiy milliy bayrami ekanligini tekshirish | `DATE '2024-03-21'` → `true` |
| `uz_utils.is_working_day(col)` | Sana ish kuni ekanligini aniqlash (Shanba, Yakshanba va bayramlar chiqariladi) | `DATE '2024-03-21'` → `false` |
| `seed: uz_holidays` | 2024–2026 yillardagi rasmiy va takrorlanuvchi milliy bayramlar ma'lumotnomasi | Reference seed |

---

### 6. 💰 Moliya va Valyuta (`finance`)

| Macro | Tavsif | Misol / Natija |
|---|---|---|
| `uz_utils.format_uzs(col)` | Summani o'qilishi qulay minglik ajratgichlar bilan formatlash | `1250000` → `'1 250 000'` |
| `uz_utils.is_post_denomination(col)` | 2017-yilgi so'm denominatsiyasidan keyingi sana ekanligini flag qilish | `DATE '2018-01-01'` → `true` |
| `uz_utils.calculate_vat_from_total(amt, vat_rate=12)` | QQS kiritilgan summadan QQS miqdorini ajratish (standart 12%) | `112000` → `12000` |
| `uz_utils.calculate_net_amount(amt, vat_rate=12)` | QQS kiritilgan summadan QQSsiz sof (net) summani hisoblash | `112000` → `100000` |
| `uz_utils.add_vat(net_amt, vat_rate=12)` | QQSsiz (net) summa ustiga QQS qo'shib brutto summani aniqlash | `100000` → `112000` |

---

### 7. 🔒 Maxfiylik va PII Himoyasi (`compliance`)

| Macro | Tavsif | Misol / Natija |
|---|---|---|
| `uz_utils.mask_pinfl(col)` | PINFL raqamini maskalash | `'31234560012345'` → `'3************5'` |
| `uz_utils.mask_phone(col)` | Telefon raqamini maskalash | `'+998901234567'` → `'+99890****567'` |
| `uz_utils.mask_passport(col)` | Pasport raqamini maskalash | `'AB 1234567'` → `'AB ****567'` |

---

## 💻 Loyihadan Foydalanish Yo'riqnomasi (Step-by-Step)

`uz_utils` kutubxonasidan dbt loyihangizda foydalanish **3 ta asosiy bosqichda** amalga oshiriladi:

### 1-bosqich: Staging modellarida ma'lumotlarni tozalash (Validation & Normalization)

Xom (raw) ma'lumotlarni formatlash, tekshirish va PII ma'lumotlarni maskalash:

```sql
-- models/staging/stg_customers.sql
select
    customer_id,

    -- 1. Shaxsiy identifikatorlarni formatlash va validatsiya
    {{ uz_utils.is_valid_pinfl('raw_pinfl') }}             as is_valid_pinfl,
    {{ uz_utils.pinfl_gender('raw_pinfl') }}               as gender,
    {{ uz_utils.pinfl_birth_date('raw_pinfl') }}           as birth_date,
    {{ uz_utils.normalize_passport('raw_passport') }}      as passport_number,

    -- 2. Telefon raqami va manzillarni standartlashtirish
    {{ uz_utils.normalize_uz_phone('raw_phone') }}          as phone_number,
    {{ uz_utils.normalize_region_name('raw_region') }}     as region_iso_code,
    {{ uz_utils.normalize_district_name('raw_district') }} as district_name,

    -- 3. Maxfiy ma'lumotlarni (PII) niqoblash
    {{ uz_utils.mask_pinfl('raw_pinfl') }}                 as pinfl_masked,
    {{ uz_utils.mask_phone('raw_phone') }}                  as phone_masked

from {{ source('raw_data', 'customers') }}
```

### 2-bosqich: Moliya va to'lov modellari (`fct_orders`, `fct_payments`)

QQS (NDS) hisoblash, to'lov kanallarini aniqlash va ish kunlarini tekshirish:

```sql
-- models/marts/fct_orders.sql
select
    order_id,
    customer_id,
    order_date,

    -- Ish kuni va bayramni aniqlash
    {{ uz_utils.is_working_day('order_date') }}            as is_working_day,
    {{ uz_utils.is_uz_holiday('order_date') }}             as is_holiday,

    -- To'lov tizimi va karta tarmog'ini aniqlash
    {{ uz_utils.detect_payment_system('payment_channel') }} as payment_system,
    {{ uz_utils.detect_card_network('card_number') }}      as card_network,

    -- Summa va QQS (12%) hisoblash
    total_amount_uzs,
    {{ uz_utils.calculate_vat_from_total('total_amount_uzs') }} as vat_amount_uzs,
    {{ uz_utils.calculate_net_amount('total_amount_uzs') }}    as net_amount_uzs,
    {{ uz_utils.format_uzs('total_amount_uzs') }}              as total_amount_formatted

from {{ ref('stg_orders') }}
```

### 3-bosqich: Ma'lumotnomalar (Seeds) bilan JOIN qilish

Kutubxonadagi `uz_regions`, `uz_districts`, `uz_banks` ma'lumotnomalaridan loyihangizda foydalanish:

```sql
-- models/marts/dim_customers.sql
select
    c.customer_id,
    c.phone_number,
    r.name_uz      as region_name,
    r.capital_uz   as region_capital,
    b.bank_name_uz as customer_bank_name

from {{ ref('stg_customers') }} c
-- Viloyatlar seed'i bilan join (ISO kodi bo'yicha)
left join {{ ref('uz_utils', 'uz_regions') }} r
    on c.region_iso_code = r.iso_code
-- Banklar seed'i bilan join (MFO kodi bo'yicha)
left join {{ ref('uz_utils', 'uz_banks') }} b
    on c.bank_mfo = b.mfo_code
```

---

## 🌐 DB Warehouse Support

Barcha macro'lar cross-database arxitekturasi (`adapter.dispatch`) asosida yozilgan.

| Ombor | Holat | Izoh |
|---|---|---|
| **PostgreSQL** | ✅ CI'da avtomatik sinaladi | Har bir PR'da `dbt build` ishga tushadi |
| **Snowflake** | ⚠️ Dispatch yozilgan, sinalmagan | CI uchun hisob ma'lumotlari kerak |
| **Google BigQuery** | ⚠️ Dispatch yozilgan, sinalmagan | CI uchun hisob ma'lumotlari kerak |
| **Amazon Redshift** | ⚠️ Dispatch yozilgan, sinalmagan | `uz_safe_cast` u yerda oddiy CAST — pastdagi izohga qarang |
| **Apache Spark / Databricks** | ⚠️ Dispatch yozilgan, sinalmagan | CI uchun klaster kerak |
| **ClickHouse** | ⚠️ Dispatch yozilgan, sinalmagan | |

> **Halollik haqida.** Faqat PostgreSQL avtomatik sinaladi. Qolgan omborlar
> uchun `adapter.dispatch` implementatsiyalari yozilgan, lekin ular haqiqiy
> omborda ishga tushirib ko'rilmagan. Agar sizda Snowflake / BigQuery /
> Databricks bo'lsa — `integration_tests` ni o'sha yerda ishga tushirib,
> natijani issue sifatida yozing yoki CI'ga service qo'shib PR yuboring.
> "✅" belgisini faqat CI tasdiqlagandan keyin qo'yamiz.

**PostgreSQL / Redshift cheklovi:** bu omborlarda `TRY_CAST` mavjud emas.
Shu sababli `uz_safe_cast()` u yerda oddiy `CAST` ga tushadi, va xavfsizlik
chaqiruvchi macro ichidagi `CASE` tekshiruvi hisobiga ta'minlanadi
(masalan `pinfl_birth_date` avval formatni va oy/kun diapazonini tekshiradi).

---

## 🧪 Integration Tests

Paketdagi barcha macro va seed'lar maxsus avtomatik testlar bilan ta'minlangan. Ularni ishga tushirish uchun:

```bash
cd integration_tests
dbt deps
dbt build     # seed → run → test, to'g'ri tartibda
```

> **MUHIM:** `dbt run` ni yolg'iz ishlatmang. Seed'ga murojaat qiluvchi
> macro'lar (`is_uz_holiday`, `is_working_day`, `mfo_to_bank_name`,
> `mfo_to_bank_short`) qiymatlarni **compile paytida** o'qiydi, ya'ni
> `uz_banks` va `uz_holidays` jadvallari omborda allaqachon mavjud
> bo'lishi kerak. `dbt build` tartibni o'zi to'g'ri hal qiladi.
> Sabablari uchun: [`macros/cross_db/_seed.sql`](macros/cross_db/_seed.sql).

---

## 🚀 Rejadagi Imkoniyatlar (Roadmap v0.3+)

- [ ] **IBAN / Bank hisob raqami validatsiyasi** (20 xonali milliy hisobraqamlar).
- [ ] **OKED klassifikatori** (`seeds/uz_oked.csv` va `is_valid_oked` macro'si).
- [ ] **Telefon operatorlari ma'lumotnomasi** (MNC kodlari bo'yicha operator nomi).
- [x] ~~**QQS (NDS) hisoblash yordamchi macro'lari**~~ — v0.2'da qo'shildi.
- [ ] **Ish kunlari kalendari**: bayram dam olish kuniga to'g'ri kelganda ko'chirish qoidasi,
      `uz_add_business_days()`, `uz_business_days_between()` (T+N hisob-kitoblar uchun).
- [ ] **Luhn algoritmi** bo'yicha karta raqami validatsiyasi (`is_valid_card_number`).

---

## 🤝 Hissa Qo'shish (Contribution)

Loyiha O'zbekiston Data hamjamiyati uchun ochiq! Agar sizda yangi macro g'oyasi yoki mavjud funksiyalarni yaxshilash taklifi bo'lsa:
1. Loyihani **Fork** qiling.
2. Yangi tarmoq yarating (`git checkout -b feature/amazing-macro`).
3. O'zgarishlarni commit qiling va **Pull Request (PR)** yuboring.

---

## 📄 Litsenziya

Ushbu loyiha [MIT Litsenziyasi](LICENSE) ostida tarqatiladi.
