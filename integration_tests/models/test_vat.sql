{{
  config(materialized='table')
}}

/*
    QQS (VAT / NDS) hisoblash macro'lari uchun integration test.
    0 qator qaytsa = barcha testlar o'tdi ✅
*/

with test_cases as (
    -- 12% standart QQS (2023+)
    select
        112000.0 as total_amt,
        100000.0 as net_amt,
        12       as rate,
        12000.0  as exp_vat,
        100000.0 as exp_net,
        112000.0 as exp_added
    union all
    -- 15% eski QQS (2019-2022)
    select
        115000.0,
        100000.0,
        15,
        15000.0,
        100000.0,
        115000.0
    union all
    -- 0% eksport QQS
    select
        500000.0,
        500000.0,
        0,
        0.0,
        500000.0,
        500000.0
),

results as (
    select
        total_amt,
        net_amt,
        rate,
        round({{ uz_utils.calculate_vat_from_total('total_amt', 'rate') }}, 2) as act_vat,
        round({{ uz_utils.calculate_net_amount('total_amt', 'rate') }}, 2)      as act_net,
        round({{ uz_utils.add_vat('net_amt', 'rate') }}, 2)                     as act_added,
        exp_vat,
        exp_net,
        exp_added
    from test_cases
)

select *
from results
where
    act_vat   != exp_vat
    or act_net   != exp_net
    or act_added != exp_added
