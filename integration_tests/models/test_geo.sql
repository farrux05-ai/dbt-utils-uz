with sample as (

    select 'Toshkent shahri' as region_a,
           'Samarkand'       as region_b,
           'Bukhara'         as region_c

)

select
    region_a,
    {{ uz_utils.normalize_region_name('region_a') }} as region_a_code,
    region_b,
    {{ uz_utils.normalize_region_name('region_b') }} as region_b_code,
    region_c,
    {{ uz_utils.normalize_region_name('region_c') }} as region_c_code

from sample
