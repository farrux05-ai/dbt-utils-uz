{#
    Tuman (district) nomini standart o'zbek nomi ko'rinishiga keltiradi.
    Natija uz_districts seed'idagi district_name_uz bilan mos keladi.

    normalize_district_name:
      Kirish: xom manzil yoki tuman nomi (ixtiyoriy katta-kichik harfda)
      Chiqish: standart "X tumani" ko'rinishi yoki null

      Misollar:
        'Yunusobod'       →  'Yunusobod tumani'
        'Yunusabad'       →  'Yunusobod tumani'    (rus transliteratsiya)
        'yunusobod'       →  'Yunusobod tumani'    (kichik harf)
        'Chilonzor r.'    →  'Chilonzor tumani'
        'Bektemir'        →  'Bektemir tumani'
        'noma'lum'       →  null

    DIQQAT:
      Bu macro faqat ENG KO'P UCHRAYDIGAN variantlarni qamrab oladi.
      Barcha tuman nomlarining barcha imlo variantlarini qamrab olish
      imkonsiz — agar sizning bazangizda boshqa variant bo'lsa, shu
      macro'ni o'z loyihangizda override qiling yoki PR yuboring.

      Toshkent shahri tumanlari (Chilonzor, Yunusobod va h.k.) ham kiradi.
#}


{% macro normalize_district_name(column) -%}
  {%- set v -%}
    lower(trim(
      {{ uz_utils.uz_regexp_replace(column, '\s*(tumani|t\.|r\.|rayoni|district)\s*$', '') }}
    ))
  {%- endset -%}
  case
    -- Toshkent shahri tumanlari
    when {{ v }} in ('chilonzor', 'chilanzar', 'чилонзор')
      then 'Chilonzor tumani'
    when {{ v }} in ('yunusobod', 'yunusabad', 'yunusabod', 'юнусобод')
      then 'Yunusobod tumani'
    when {{ v }} in ('mirzo ulug''bek', 'mirzo ulugbek', 'мирзо улугбек')
      then 'Mirzo Ulug''bek tumani'
    when {{ v }} in ('olmazor', 'алмазар', 'almazar')
      then 'Olmazor tumani'
    when {{ v }} in ('uchtepa', 'учтепа')
      then 'Uchtepa tumani'
    when {{ v }} in ('yakkasaroy', 'яккасарой')
      then 'Yakkasaroy tumani'
    when {{ v }} in ('shayxontohur', 'shayhontohur', 'шайхантахур')
      then 'Shayxontohur tumani'
    when {{ v }} in ('yashnobod', 'яшнобод')
      then 'Yashnobod tumani'
    when {{ v }} in ('bektemir', 'бектемир')
      then 'Bektemir tumani'
    when {{ v }} in ('mirobod', 'мирабад')
      then 'Mirobod tumani'
    when {{ v }} in ('sergeli', 'сергели')
      then 'Sergeli tumani'

    -- Andijon viloyati
    when {{ v }} in ('andijon', 'andijan', 'андижон')
      then 'Andijon tumani'
    when {{ v }} in ('asaka', 'асака')
      then 'Asaka tumani'
    when {{ v }} in ('shahrixon', 'shahrihan', 'шахрихон')
      then 'Shahrixon tumani'
    when {{ v }} in ('marhamat', 'мархамат')
      then 'Marhamat tumani'

    -- Buxoro viloyati
    when {{ v }} in ('buxoro', 'bukhara', 'бухара')
      then 'Buxoro tumani'
    when {{ v }} in ('g''ijduvon', 'gijduvon', 'ghijduvon', 'гиждувон')
      then 'G''ijduvon tumani'
    when {{ v }} in ('shofirkon', 'шофиркон')
      then 'Shofirkon tumani'
    when {{ v }} in ('romitan', 'ромитан')
      then 'Romitan tumani'
    when {{ v }} in ('vobkent', 'вобкент')
      then 'Vobkent tumani'

    -- Farg'ona viloyati
    when {{ v }} in ('farg''ona', 'fargona', 'fergana', 'ferghana', 'фаргона')
      then 'Farg''ona tumani'
    when {{ v }} in ('marg''ilon', 'margilan', 'маргилан')
      then 'Marg''ilon tumani'
    when {{ v }} in ('qo''qon', 'qoqon', 'kokand', 'кокандский')
      then 'Qo''qon tumani'
    when {{ v }} in ('rishton', 'риштон')
      then 'Rishton tumani'

    -- Samarqand viloyati
    when {{ v }} in ('samarqand', 'samarkand', 'самарканд')
      then 'Samarqand tumani'
    when {{ v }} in ('urgut', 'ургут')
      then 'Urgut tumani'
    when {{ v }} in ('kattaqo''rg''on', 'kattaqorgon', 'каттакурган')
      then 'Kattaqo''rg''on tumani'

    -- Namangan viloyati
    when {{ v }} in ('namangan', 'наманган')
      then 'Namangan tumani'
    when {{ v }} in ('chust', 'чуст')
      then 'Chust tumani'
    when {{ v }} in ('pop', 'поп')
      then 'Pop tumani'

    -- Navoiy viloyati
    when {{ v }} in ('navoiy', 'navoi', 'навои')
      then 'Navoiy tumani'
    when {{ v }} in ('nurota', 'нурата')
      then 'Nurota tumani'

    -- Qashqadaryo viloyati
    when {{ v }} in ('qarshi', 'karshi', 'карши')
      then 'Qarshi tumani'
    when {{ v }} in ('shahrisabz', 'shakhrisabz', 'шахрисабз')
      then 'Shahrisabz tumani'
    when {{ v }} in ('kitob', 'kitab', 'китаб')
      then 'Kitob tumani'

    -- Surxondaryo viloyati
    when {{ v }} in ('termiz', 'termez', 'термез')
      then 'Termiz tumani'
    when {{ v }} in ('denov', 'денов')
      then 'Denov tumani'
    when {{ v }} in ('sherobod', 'шерабад')
      then 'Sherobod tumani'

    -- Sirdaryo viloyati
    when {{ v }} in ('guliston', 'гулистон')
      then 'Guliston tumani'
    when {{ v }} in ('yangiyer', 'янгиер')
      then 'Yangiyer tumani'

    -- Toshkent viloyati
    when {{ v }} in ('bekabad', 'beqobod', 'бекабад')
      then 'Bekabad tumani'
    when {{ v }} in ('ohangaron', 'ахангаран')
      then 'Ohangaron tumani'
    when {{ v }} in ('yangiyo''l', 'yangiyul', 'янгиюль')
      then 'Yangiyo''l tumani'
    when {{ v }} in ('qibray', 'кибрай')
      then 'Qibray tumani'

    -- Xorazm viloyati
    when {{ v }} in ('urganch', 'urgench', 'ургенч')
      then 'Urganch tumani'
    when {{ v }} in ('xiva', 'khiva', 'хива')
      then 'Xiva tumani'

    -- Qoraqalpog'iston
    when {{ v }} in ('nukus', 'нукус')
      then 'Nukus tumani'
    when {{ v }} in ('beruniy', 'biruni', 'беруний')
      then 'Beruniy tumani'

    else null
  end
{%- endmacro %}
