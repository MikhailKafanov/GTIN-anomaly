/*
 * Задача: получить все штрих-кода всех уровней начинающиеся на 2 только по локальным активным SKU, исключив артикулы гаммы TR, R, S
 */
/*
*Делаем библиотеку активных артикулов по условию: если на товаре есть хотя бы один магазин в статусах активный, неактивны;
 */
with active_sku as
(
	select distinct gm.item
	, primary_supp as supplier
	from rms_p009qtzb_rms_ods.v_uda_item_lov gm
	inner join rms_p009qtzb_rms_ods.v_item_loc il on gm.item = il.item
	where gm.uda_id = 5
	and 
		(il.loc_type = 'S' 
		and il.status in ('A', 'I')
		and il.loc not in (351,352,397,399,1,66,168,396,398,395) 
		)
	and il.primary_supp in (SELECT supplier 
							FROM rms_p009qtzb_rms_ods.v_sups 
							WHERE SUP_STATUS = 'A' 
							) --берем только активных поставщиков
	and il.primary_supp not in (select supplier 
								from rms_p009qtzb_rms_ods.v_item_supplier 
								where substring(text(supplier), 8 ,1) = '7' 
								or supplier in ('100020701', '100013702', '115903703', '108814705')
								) -- исключаем поставщиков ПРО
	and gm.uda_value not in (6, 15, 17)	 -- исключаем гаммы S, R, TR
	and gm.item not in (select key_value from rms_p009qtzb_rms_ods.v_daily_purge) --исключаем товары со статусами "Удален" в RMS
	and substring(text(il.primary_supp),1,3) <> '199' -- исключаем поставщиков импорта
)
/*
*берем шк штуки начинающиеся на 2
*/
, ea_gtin as
( 	select im.item_parent as item
	,im.item as gtin
	,isupp.supplier
	, case when im.nk is not null then 'Штука'
	end as "gtin_level" -- указываю уровень, сделав проверку через первичный ключ
	from rms_p009qtzb_rms_ods.v_item_master im
	left join rms_p009qtzb_rms_ods.v_item_supplier isupp on im.item_parent = isupp.item
	where im.item_parent is not null
	and substring(text(im.item), 1, 1) = '2' 
)
/*
 * Выводим итоговый результат, для информации добавляем название лм-кода и номер отдела.
 */
select ag.item
,im.item_desc
,ag.gtin
,ag.supplier
, d.group_no as dep
from ea_gtin ag
inner join active_sku ac on ag.item = ac.item
and ag.supplier = ac.supplier
left join rms_p009qtzb_rms_ods.v_item_master im 
on im.item = ag.item
left join rms_p009qtzb_rms_ods.v_deps d on d.dept = im.dept
