select distinct isc.item as "Артикул"
    , ean.item as "ШК"
    , isc.supplier as "Поставщик"
    , d.group_no "Отдел"
    , isg_in.gtin as "ШК на уровне Inner"
    , isg_ca.gtin as "ШК на уровне Outer"
    , im.standard_uom as "ЕИ"
    , im.create_datetime as "Дата создания"
    , case 
        when ean.item = isg_in.gtin
        then 'Ошибка. ШК штуки не может быть равен ШК inner'
    end "Ошибка 1"
    , case 
        when ean.item = isg_ca.gtin
        then 'Ошибка. ШК штуки не может быть равен ШК outer'
    end "Ошибка 2"
    , case 
        when isg_ca.gtin = isg_in.gtin
        then 'Ошибка. ШК outer не может быть равен ШК inner'
    end "Ошибка 3"
from rms_p009qtzb_rms_ods.v_item_supp_country isc
left join (select item, supplier, gtin from rms_p009qtzb_rms_ods.v_xxlm_item_supp_gtin where dim_object = 'IN' and is_actual = '1') isg_in on isg_in.item = isc.item and isc.supplier = isg_in.supplier
left join (select item, supplier, gtin from rms_p009qtzb_rms_ods.v_xxlm_item_supp_gtin where dim_object = 'CA' and is_actual = '1') isg_ca on isg_ca.item = isc.item and isc.supplier = isg_ca.supplier
left join (select item, dept, standard_uom, create_datetime from rms_p009qtzb_rms_ods.v_item_master where item_number_type = 'ITEM' and is_actual = '1') im on im.item = isc.item
left join (select dept, group_no from rms_p009qtzb_rms_ods.v_deps where is_actual='1') d on d.dept = im.dept
left join (select item, item_parent from rms_p009qtzb_rms_ods.v_item_master where is_actual = '1' and item_number_type = 'EAN13') ean on ean.item_parent = isc.item
where isc.item not in (select item from rms_p009qtzb_rms_ods.v_uda_item_date where uda_id = 6 and uda_date < current_date and is_actual = '1')
and isc.item not in (select item from rms_p009qtzb_rms_ods.v_uda_item_lov where uda_id = 5 and uda_value in (15,6) and is_actual = '1')
and (ean.item = isg_in.gtin or ean.item = isg_ca.gtin or isg_ca.gtin = isg_in.gtin) and isc.is_actual = '1'