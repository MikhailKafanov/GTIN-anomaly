select distinct isc.item as "Артикул"
     , im.item_desc as "Название"
     ,im2.item as "ШК штуки"
    , isc.supplier as "Поставщик"
    , d.group_no "Отдел"
    , isc.inner_pack_size as "Расфасовка Inner"
    , isg_in.gtin as "ШК на уровне Inner"
    , isc.supp_pack_size as "Расфасовка Outer"
    , isg_ca.gtin as "ШК на уровне Outer"
    , im.standard_uom as "ЕИ"
    , im.create_datetime as "Дата создания"
    , case 
          when isc.supplier in (select distinct Supplier from rms_p009qtzb_rms_ods.v_xxlm_path_header xph 
                              left join (select * from rms_p009qtzb_rms_ods.v_xxlm_path_version where is_actual = '1') xpv on xph.id = xpv.id
                              where xph.loc_type = 'S' and xpv.cd_wh is not null and xph.loc not in (351,352,397,399, 398) and xpv.ACTIVE_IND = 'Y' and cd_wh in ('922060', '922063') and xph.is_actual = '1')
          then '1'
     end "Проверка BBXD"
     , isc.min_order_qty as "Минимальное количество для заказа"
       , case 
        when isc.round_lvl = 'LP'
        then 'Уровень/Паллета'
        when isc.round_lvl = 'СLP'
        then 'Ящик/Уровень/Паллета'
        when isc.round_lvl = 'P'
        then 'Паллета'
        when isc.round_lvl = 'I'
        then 'Inner'
        when isc.round_lvl = 'C'
        then 'Ящик'
        when isc.round_lvl = 'L'
        then 'Уровень'
       end "Уровень округления"
from rms_p009qtzb_rms_ods.v_item_supp_country isc
inner join (select * from rms_p009qtzb_rms_ods.v_item_master where item_number_type = 'ITEM' and is_actual = '1') im on im.item = isc.item
left join (select item_parent,item  from rms_p009qtzb_rms_ods.v_item_master where is_actual = '1' and item_number_type = 'EAN13' AnD primary_ref_item_ind = 'Y') im2 on im2.item_parent = isc.item
left join (select * from rms_p009qtzb_rms_ods.v_xxlm_item_supp_gtin where dim_object = 'IN' and is_actual = '1') isg_in on isg_in.item = isc.item and isc.supplier = isg_in.supplier
left join (select * from rms_p009qtzb_rms_ods.v_xxlm_item_supp_gtin where dim_object = 'CA' and is_actual = '1') isg_ca on isg_ca.item = isc.item and isc.supplier = isg_ca.supplier
left join (select dept, group_no from rms_p009qtzb_rms_ods.v_deps where is_actual='1') d on d.dept = im.dept
inner join (select item, primary_supp, loc, status from rms_p009qtzb_rms_ods.v_item_loc  where is_actual = '1' 
and loc not in (351,352,397,399,1,66,168,396,398,395, 66) and (loc_type = 'S' and status in ('A', 'I')
or (loc_type = 'W' and substring(text(primary_supp),1,3) = '199' and substring(text(loc),1,3) in ('912','922','921','908','906') and status = 'A'))) il on il.item = isc.item and isc.supplier = il.primary_supp
where (((isc.supp_pack_size > 1 and isg_ca.gtin is null))
or ((isc.inner_pack_size > 1 and isg_in.gtin is null)))
and isc.item not in (select distinct(item) from rms_p009qtzb_rms_ods.v_uda_item_date where uda_id = 6 and uda_date < current_date and is_actual = '1') 
and isc.item not in (select distinct(item) from rms_p009qtzb_rms_ods.v_uda_item_lov where uda_id = 5 and uda_value in (6, 15) and is_actual = '1')
and isc.supplier not in (select supplier from rms_p009qtzb_rms_ods.v_item_supplier where substring(text(supplier), 8 ,1) = '7'  or supplier in ('100020701', '100013702', '115903703', '108814705') and is_actual='1')
and isc.is_actual ='1'
AND isc.supplier IN (SELECT supplier FROM rms_p009qtzb_rms_ods.v_sups WHERE is_actual = '1' AND SUP_STATUS = 'A' AND supplier = isc.supplier)

