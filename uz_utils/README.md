# uz_utils

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
  - git: "https://github.com/<sizning-username>/dbt-uz.git"
    subdirectory: "uz_utils"
    revision: main
```

Keyin:

```bash
dbt deps
```

---

## Macro'lar

### 🪪 Identifikatorlar

O'zbekistonda ikki turdagi asosiy identifikator bor: jismoniy shaxslar uchun **PINFL** (14 xona), yuridik shaxslar uchun **STIR/INN** (9 xona).

| Macro | Nima qiladi |
|---|---|
| `uz_utils.is_valid_pinfl(column)` | PINFL formatini tekshiradi (14 raqam + 1–6 birinchi xona) |
| `uz_utils.pinfl_gender(column)` | PINFL'dan jinsni ajratadi → `erkak` yoki `ayol` |
| `uz_utils.pinfl_birth_date(column)` | PINFL'dan tug'ilgan sanani ajratadi → `DATE` turi |
| `uz_utils.pinfl_region_code(column)` | PINFL'dan hudud kodini ajratadi (8–10-xonalar) |
| `uz_utils.is_valid_stir(column)` | STIR/INN formatini tekshiradi (9 raqam) |

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

O'zbek raqamlar bazalarda ko'plab formatlarda saqlangan bo'ladi. Bu macro'lar ularni standartlashtiradi.

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

> **Eslatma:** Operator kodi ajratiladi, lekin operator nomiga (`UzMobile`, `Beeline` va h.k.) map qilinmaydi — bu ro'yxat tez-tez o'zgaradi, shuning uchun uni seed orqali o'z loyihangizda saqlash tavsiya etiladi.

---

### 💳 To'lov tizimlari

UzCard va Humo kartalari O'zbekistonga xos BIN raqamlariga ega.

| Macro | Nima qiladi |
|---|---|
| `uz_utils.detect_card_network(column)` | Karta tizimini aniqlaydi |
| `uz_utils.mask_card_number(column)` | Karta raqamini PII uchun maskalaydi |

**`detect_card_network` natijasi:**

| BIN | Natija |
|---|---|
| `8600****` | `uzcard` |
| `9860****` | `humo` |
| `4*******` | `visa` |
| `51–55****` | `mastercard` |
| `62******` | `unionpay` |
| boshqa | `unknown` |

**`mask_card_number` misoli:**

```
8600123456781234  →  8600 **** **** 1234
```

---

### 🗺️ Hudud (geo)

| Macro / Seed | Nima qiladi |
|---|---|
| `uz_utils.normalize_region_name(column)` | Xilma-xil yozilgan hudud nomini ISO 3166-2:UZ kodiga keltiradi |
| `seed: uz_regions` | 14 ta hudud: ISO kod, uz/en/ru nomi, markaz shahri |

**`normalize_region_name` misollari:**

```sql
'Toshkent shahri'  →  'UZ-TK'
'Tashkent city'    →  'UZ-TK'
'г.Ташкент'        →  'UZ-TK'
'Andijon'          →  'UZ-AN'
'Fergana region'   →  'UZ-FA'
"Farg'ona"         →  'UZ-FA'
```

> ⚠️ `"Toshkent"` yolg'iz holda `NULL` qaytaradi — bu shahar (UZ-TK) yoki viloyat (UZ-TO) ekanligi noaniq. Agar sizning ma'lumotlaringizda bu so'z doim bitta narsani anglatsa, macro'ni o'z loyihangizda override qiling.

**`uz_regions` seed foydalanish:**

```sql
select
    c.customer_id,
    r.name_uz,
    r.name_en,
    r.capital_uz
from {{ ref('stg_customers') }} c
left join {{ ref('uz_utils', 'uz_regions') }} r
    on {{ uz_utils.normalize_region_name('c.region_raw') }} = r.iso_code
```

---

### ⚙️ Cross-database (ichki)

`macros/cross_db/_regexp.sql` — barcha regex operatsiyalar shu fayl orqali yo'naltiriladi. Yangi warehouse qo'shish uchun shu faylga `<adapter_nomi>__uz_regexp_like` va `<adapter_nomi>__uz_regexp_replace` qo'shish kifoya.

**Qo'llab-quvvatlanadigan warehouse'lar:**

| Warehouse | Holat |
|---|---|
| PostgreSQL | ✅ Sinovdan o'tgan |
| Redshift | ✅ Sinovdan o'tgan |
| BigQuery | ✅ Sinovdan o'tgan |
| Snowflake | ✅ Default |
| Spark | ✅ Sinovdan o'tgan |
| Databricks | ✅ Sinovdan o'tgan |
| ClickHouse | ⚠️ Mantiqiy jihatdan to'g'ri, lekin real instansiyada sinovdan o'tmagan |

---

## Foydalanish misoli

```sql
-- models/staging/stg_customers_enriched.sql
select
    customer_id,
    customer_pinfl,

    -- Identifikator validatsiyasi
    {{ uz_utils.is_valid_pinfl('customer_pinfl') }}    as pinfl_is_valid,
    {{ uz_utils.pinfl_gender('customer_pinfl') }}      as gender,
    {{ uz_utils.pinfl_birth_date('customer_pinfl') }}  as birth_date,

    -- Telefon normalizatsiyasi
    {{ uz_utils.normalize_uz_phone('raw_phone') }}     as phone_normalized,
    {{ uz_utils.uz_phone_operator('raw_phone') }}      as phone_operator_code,

    -- Karta
    {{ uz_utils.detect_card_network('card_number') }}  as card_network,
    {{ uz_utils.mask_card_number('card_number') }}     as card_masked,

    -- Hudud
    {{ uz_utils.normalize_region_name('region_raw') }} as region_iso

from {{ ref('raw_customers') }}
```

---

## Rejadagi macro'lar (v0.2+)

Bu yerda ishni osonlashtirishi mumkin bo'lgan keyingi macro'lar g'oyalari bor. Har biri kimningdir kunlik manual ishi bo'lgan muammo. **Agar sizda ham shunday takroriy ish bo'lsa — quyidagi bo'limga qo'shing yoki PR yuboring.**

### Tuman (district) ma'lumotnomasi
- O'zbekistondagi 175 ta tuman va shaharning reference seed'i
- Har bir tuman ISO viloyat kodi bilan bog'langan
- Foydalanish: manzil normalizatsiyasi, geo tahlil

### Milliy bayramlar va ish kunlari
- O'zbekiston milliy bayramlari seed'i (yillik yangilanadi)
- `uz_utils.is_working_day(date_column)` macro'si
- Foydalanish: SLA hisoblash, kechikish tahlili, to'lov muddatlarini hisoblash

### So'm formatlash
- `uz_utils.format_uzs(amount_column)` — minglik ajratgich bilan (`1 250 000 so'm`)
- 2017-yil denominatsiya eslatmasi (eski vs yangi so'm)

### IBAN / hisob raqam tekshiruvi
- O'zbekiston bank hisob raqami formatini validatsiya qilish (20 xonali)
- Foydalanish: fintech, bank to'lovlarini qayta ishlash

### Passport seriya + raqam
- O'zbekiston pasporti formatini tekshirish (AA 1234567)
- Foydalanish: shaxs identifikatsiyasi

### To'lov tizimi operatori
- CLICK, Payme, Apelsin, Uzum Bank tranzaksiya ma'lumotlarini normalizatsiya
- Foydalanish: to'lov kanal tahlili

### MFO (bank kodi) ma'lumotnomasi
- O'zbekiston banklarining MFO kodlari seed'i
- `uz_utils.mfo_to_bank_name(column)` macro'si

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
