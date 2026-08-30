{#
    Bu model faqat macro'larni "silliq ishlayaptimi" deb tekshirish uchun.
    Haqiqiy unit-testlar uchun dbt'ning unit test funksiyasidan
    (schema.yml ichida `unit_tests:`) foydalanish tavsiya etiladi.
#}

with sample as (

    select '123456789'      as stir_ok,
           '12345678'       as stir_bad,      -- 8 xonali, noto'g'ri
           '31210630123459' as pinfl_ok,      -- 1963-10-12, erkak
           '998901234567'   as phone_a,
           '0901234567'     as phone_b,
           '8600570012341234' as card_uzcard,
           '9860270112341234' as card_humo

)

select
    stir_ok,
    {{ uz_utils.is_valid_stir('stir_ok') }}   as stir_ok_is_valid,
    stir_bad,
    {{ uz_utils.is_valid_stir('stir_bad') }}  as stir_bad_is_valid,

    pinfl_ok,
    {{ uz_utils.is_valid_pinfl('pinfl_ok') }} as pinfl_is_valid,
    {{ uz_utils.pinfl_gender('pinfl_ok') }}   as pinfl_gender,
    {{ uz_utils.pinfl_birth_date('pinfl_ok') }} as pinfl_birth_date,

    {{ uz_utils.normalize_uz_phone('phone_a') }} as phone_a_normalized,
    {{ uz_utils.normalize_uz_phone('phone_b') }} as phone_b_normalized,

    {{ uz_utils.detect_card_network('card_uzcard') }} as card_uzcard_network,
    {{ uz_utils.detect_card_network('card_humo') }}   as card_humo_network,
    {{ uz_utils.mask_card_number('card_uzcard') }}    as card_uzcard_masked

from sample
