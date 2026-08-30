{{
  config(materialized='table')
}}

/*
    Payment system, MFO, currency va PII macro'lari uchun test.
    0 qator = barcha testlar o'tdi ✅
*/

-- detect_payment_system
with ps_cases as (
    select 'click'       as raw, 'click'         as exp union all
    select 'CLICK',              'click'                union all
    select 'Click.uz',           'click'                union all
    select 'payme',              'payme'                union all
    select 'PayMe',              'payme'                union all
    select 'apelsin',            'apelsin'              union all
    select 'uzum bank',          'uzum'                 union all
    select 'bank_transfer',      'bank_transfer'        union all
    select 'naqd',               'cash'                 union all
    select null,                 'unknown'              union all
    select 'SMS pay',            'unknown'
),

ps_results as (
    select
        raw,
        exp,
        {{ uz_utils.detect_payment_system('raw') }} as act
    from ps_cases
    where {{ uz_utils.detect_payment_system('raw') }} != exp
),

-- is_valid_mfo
mfo_cases as (
    select '00873' as mfo, true  as exp_valid union all
    select '01014',        true               union all
    select '873',          false              union all  -- 3 xona
    select '008731',       false              union all  -- 6 xona
    select 'ABCDE',        false              union all  -- harf
    select null,           false
),

mfo_results as (
    select
        mfo,
        exp_valid,
        {{ uz_utils.is_valid_mfo('mfo') }} as act_valid
    from mfo_cases
    where {{ uz_utils.is_valid_mfo('mfo') }} != exp_valid
),

-- format_uzs
uzs_cases as (
    select 1250000 as amt, '1 250 000' as exp union all
    select 999,            '999'              union all
    select 0,              '0'                union all
    select 1000000000,     '1 000 000 000'
),

uzs_results as (
    select
        amt,
        exp,
        {{ uz_utils.format_uzs('amt') }} as act
    from uzs_cases
    where {{ uz_utils.format_uzs('amt') }} != exp
),

-- is_post_denomination
denom_cases as (
    select date '2017-09-30' as d, false as exp union all
    select date '2017-10-01',      true         union all
    select date '2024-01-01',      true
),

denom_results as (
    select
        d,
        exp,
        {{ uz_utils.is_post_denomination('d') }} as act
    from denom_cases
    where {{ uz_utils.is_post_denomination('d') }} != exp
),

-- mask_pinfl
pii_cases as (
    select '31234560012345' as pinfl, '3************5' as exp_mask
),

pii_results as (
    select
        pinfl,
        exp_mask,
        {{ uz_utils.mask_pinfl('pinfl') }} as act_mask
    from pii_cases
    where {{ uz_utils.mask_pinfl('pinfl') }} != exp_mask
)

select 'detect_payment_system' as macro_name, raw::text as input, exp as expected, act as actual from ps_results
union all
select 'is_valid_mfo',          mfo,           exp_valid::text,    act_valid::text from mfo_results
union all
select 'format_uzs',            amt::text,     exp,                act             from uzs_results
union all
select 'is_post_denomination',  d::text,       exp::text,          act::text       from denom_results
union all
select 'mask_pinfl',            pinfl,         exp_mask,           act_mask        from pii_results
