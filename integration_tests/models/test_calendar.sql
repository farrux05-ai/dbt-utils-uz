{{
  config(materialized='table')
}}

/*
    Calendar macro'lari uchun integration test.
    is_uz_holiday va is_working_day ni tekshiradi.
    0 qator = barcha testlar o'tdi ✅
*/

with test_cases as (
    -- Milliy bayramlar
    select date '2024-01-01' as d, true  as exp_holiday, false as exp_working union all  -- Yangi yil
    select date '2024-03-21',      true,                 false               union all  -- Navro'z
    select date '2024-09-01',      true,                 false               union all  -- Mustaqillik
    select date '2024-12-08',      true,                 false               union all  -- Konstitutsiya
    -- Hafta kunlari (ish kunlari)
    select date '2024-03-18',      false,                true                union all  -- Dushanba
    select date '2024-03-19',      false,                true                union all  -- Seshanba
    select date '2024-03-20',      false,                true                union all  -- Chorshanba
    -- Dam olish kunlari (shanba, yakshanba)
    select date '2024-03-23',      false,                false               union all  -- Shanba
    select date '2024-03-24',      false,                false               union all  -- Yakshanba
    -- Bayram + hafta sonu birgalikda
    select date '2025-03-08',      true,                 false               union all  -- Xotin-qizlar kuni
    select date '2025-05-09',      true,                 false                          -- Xotira kuni
),

results as (
    select
        d,
        exp_holiday,
        {{ uz_utils.is_uz_holiday('d') }}   as act_holiday,
        exp_working,
        {{ uz_utils.is_working_day('d') }}  as act_working
    from test_cases
)

select *
from results
where
    act_holiday is distinct from exp_holiday
    or act_working  is distinct from exp_working
