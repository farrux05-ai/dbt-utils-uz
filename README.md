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

## 💻 Amaliy Foydalanish Misoli

Staging qatlamidagi dbt modelida macro'lardan foydalanish:

```sql
-- models/staging/stg_customers.sql
select
    customer_id,

    -- Shaxsiy identifikatorlar
    {{ uz_utils.is_valid_pinfl('raw_pinfl') }}             as is_valid_pinfl,
    {{ uz_utils.pinfl_gender('raw_pinfl') }}               as gender,
    {{ uz_utils.pinfl_birth_date('raw_pinfl') }}           as birth_date,
    {{ uz_utils.normalize_passport('raw_passport') }}      as passport_number,

    -- Aloqa va Geografiya
    {{ uz_utils.normalize_uz_phone('raw_phone') }}          as phone_number,
    {{ uz_utils.normalize_region_name('raw_region') }}     as region_iso_code,
    {{ uz_utils.normalize_district_name('raw_district') }} as district_name,

    -- To'lovlar va Ish kunlari
    {{ uz_utils.detect_payment_system('payment_channel') }} as payment_system,
    {{ uz_utils.is_working_day('created_at') }}             as is_created_on_working_day,

    -- Mart/Analytics uchun PII maskalash
    {{ uz_utils.mask_pinfl('raw_pinfl') }}                 as pinfl_masked,
    {{ uz_utils.mask_phone('raw_phone') }}                  as phone_masked

from {{ source('raw_data', 'customers') }}
```

---

## 🌐 DB Warehouse Support

Barcha macro'lar cross-database arxitekturasi (`adapter.dispatch`) asosida yozilgan va quyidagi omborlarda ishlaydi:

- **PostgreSQL** ✅
- **Snowflake** ✅
- **Google BigQuery** ✅
- **Amazon Redshift** ✅
- **Apache Spark / Databricks** ✅
- **ClickHouse** ⚠️ *(Sinov bosqichida)*

---

## 🧪 Integration Tests

Paketdagi barcha macro va seed'lar maxsus avtomatik testlar bilan ta'minlangan. Ularni ishga tushirish uchun:

```bash
cd integration_tests
dbt deps
dbt seed
dbt run
dbt test
```

---

## 🚀 Rejadagi Imkoniyatlar (Roadmap v0.3+)

- [ ] **IBAN / Bank hisob raqami validatsiyasi** (20 xonali milliy hisobraqamlar).
- [ ] **OKED klassifikatori** (`seeds/uz_oked.csv` va `is_valid_oked` macro'si).
- [ ] **Telefon operatorlari ma'lumotnomasi** (MNC kodlari bo'yicha operator nomi).
- [ ] **QQS (NDS) hisoblash yordamchi macro'lari**.

---

## 🤝 Hissa Qo'shish (Contribution)

Loyiha O'zbekiston Data hamjamiyati uchun ochiq! Agar sizda yangi macro g'oyasi yoki mavjud funksiyalarni yaxshilash taklifi bo'lsa:
1. Loyihani **Fork** qiling.
2. Yangi tarmoq yarating (`git checkout -b feature/amazing-macro`).
3. O'zgarishlarni commit qiling va **Pull Request (PR)** yuboring.

---

## 📄 Litsenziya

Ushbu loyiha [MIT Litsenziyasi](LICENSE) ostida tarqatiladi.
