with 
--берем все исторические данные по товарам, где расфасовка outer != 1
hpd as (
select item, supplier,  valid_from_dttm, case when valid_to_dttm is null then current_date else valid_to_dttm end as valid_to_dttm
from rms_p009qtzb_rms_ods.v_item_supp_country_hist
where supp_pack_size != 1 and supplier not in (select supplier 
												from rms_p009qtzb_rms_ods.v_item_supplier 
												where substring(text(supplier), 8 ,1) = '7'  
												or supplier in ('100020701', '100013702', '115903703', '108814705'))
),
---берем данные по появлению первого gtin
gtd as (
select item, supplier,min(create_datetime) over (partition by item, supplier order by create_datetime) as gtin_date
from rms_p009qtzb_rms_ods.v_xxlm_item_supp_gtin 
where dim_object = 'CA' 
),
-- создаем библиотеку отделов
deps as 
(select im.item, d.group_no  from rms_p009qtzb_rms_ods.v_item_master im
inner join rms_p009qtzb_rms_ods.v_deps d on im.dept = d.dept
where im.item_number_type = 'ITEM'),
-- исключюем все связки, где дата появления упаковки >1 = минимальной дате появления шк 
pd as( 
select distinct hpd.item, hpd.supplier, gtd.gtin_date, max(hpd.valid_to_dttm) over (partition by hpd.item, hpd.supplier) as fix_pack_date,
min(hpd.valid_from_dttm) over (partition by hpd.item, hpd.supplier) as create_pack_date from hpd
left join gtd on gtd.item = hpd.item and gtd.supplier = hpd.supplier),
end_result as(
select * from pd 
where gtin_date is null
and fix_pack_date != current_date
and fix_pack_date > '2022-07-01'
union all
select * from pd 
where date(gtin_date) > date(create_pack_date) -- дата подвеса шк должна быть после появления упаковки > 1, т.к. шк может быть и на 1 
and gtin_date > '2022-07-01'--and create_pack_date < '2022-07-01'
--and fix_pack_date != current_date -- если дата равна то исправлен шк, если больше
order by 1, 2)
select deps.group_no,r.*  from end_result r
left join deps on r.item = deps.item