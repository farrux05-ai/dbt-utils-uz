{#
    Xom ma'lumotlarda hudud nomi ko'plab turli shaklda uchraydi:
    'Toshkent shahri' / 'Tashkent city' / 'г.Ташкент' / 'TSH' va h.k.
    Bu macro eng keng tarqalgan variantlarni ISO 3166-2:UZ koduga (uz_regions
    seedidagi iso_code bilan mos) keltiradi.

    DIQQAT: 'Toshkent' / 'Tashkent' so'zi yolg'iz holda (shahri/viloyati
    qo'shimchasisiz) qaysi hudud — shahar (UZ-TK) yoki viloyat (UZ-TO) —
    ekanligi noaniq. Shu sababli bu holatlar ATAYLAB xaritalanmagan (NULL
    qaytadi) — noto'g'ri taxmin qilishdan ko'ra aniqlik so'ragan ma'qul.
    Agar sizning ma'lumotlaringizda 'Toshkent' doim bitta narsani
    (masalan doim shahar) anglatishini bilsangiz, bu macro'ni öz loyihangizda
    override qiling.
#}

{% macro normalize_region_name(column) -%}
  {%- set v -%}
    lower(trim({{ column }}))
  {%- endset -%}
  case
    when {{ v }} in ('andijon','andijan','andijon viloyati','andijan region') then 'UZ-AN'
    when {{ v }} in ('buxoro','bukhara','buxoro viloyati','bukhara region') then 'UZ-BU'
    when {{ v }} in ('farg''ona','fargona','fergana','ferghana','farg''ona viloyati','fergana region') then 'UZ-FA'
    when {{ v }} in ('jizzax','jizzakh','jizzax viloyati','jizzakh region') then 'UZ-JI'
    when {{ v }} in ('namangan','namangan viloyati','namangan region') then 'UZ-NG'
    when {{ v }} in ('navoiy','navoi','navoiy viloyati','navoiy region') then 'UZ-NW'
    when {{ v }} in ('qashqadaryo','kashkadarya','kashkadaryo','qashqadaryo viloyati') then 'UZ-QA'
    when {{ v }} in ('qoraqalpog''iston','qoraqalpogiston','karakalpakstan','qoraqalpogiston respublikasi') then 'UZ-QR'
    when {{ v }} in ('samarqand','samarkand','samarqand viloyati','samarkand region') then 'UZ-SA'
    when {{ v }} in ('sirdaryo','sirdarya','sirdaryo viloyati') then 'UZ-SI'
    when {{ v }} in ('surxondaryo','surkhandarya','surxondaryo viloyati') then 'UZ-SU'
    when {{ v }} in ('xorazm','khorezm','khorazm','xorazm viloyati','khorezm region') then 'UZ-XO'
    when {{ v }} in ('toshkent shahri','tashkent city','g. toshkent','g.toshkent','toshkent sh.') then 'UZ-TK'
    when {{ v }} in ('toshkent viloyati','tashkent region','tashkent oblast') then 'UZ-TO'
    else null
  end
{%- endmacro %}
