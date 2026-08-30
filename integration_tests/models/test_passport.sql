{{
  config(materialized='table')
}}

/*
    Passport macro'lari uchun integration test.
    Agar bu model 0 qator qaytarsa — barcha testlar o'tdi ✅
    Agar qator bo'lsa — xato: qaysi test muvaffaqiyatsiz ekanligini ko'rsatadi.
*/

with test_cases as (
    select 'AB 1234567'  as raw,  true   as exp_valid, 'AB 1234567' as exp_norm union all
    select 'ab1234567',           false,               'AB 1234567'             union all
    select 'AB1234567',           false,               'AB 1234567'             union all
    select 'AB-1234567',          false,               'AB 1234567'             union all
    select 'AB 123456',           false,               null                     union all  -- 6 raqam
    select '1B 1234567',          false,               null                     union all  -- birinchi xona raqam
    select 'ABC1234567',          false,               null                     union all  -- 3 harf
    select null,                  false,               null
),

results as (
    select
        raw,
        exp_valid,
        {{ uz_utils.is_valid_passport('raw') }}    as act_valid,
        exp_norm,
        {{ uz_utils.normalize_passport('raw') }}   as act_norm
    from test_cases
)

select *
from results
where
    act_valid != exp_valid
    or (act_norm is null and exp_norm is not null)
    or (act_norm is not null and exp_norm is null)
    or act_norm != exp_norm
