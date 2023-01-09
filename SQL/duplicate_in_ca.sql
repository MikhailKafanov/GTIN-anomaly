select im.item as "ШК штуки"
     , im.item_parent as "ЛМ_1"
     , d.group_no as "Отдел_1"
     , val1.uda_value_desc as "Гамма_1"
     , gtin.gtin as "ШК Inner"
     , gtin.item as "ЛМ_2"
     , gtin.supplier as "Поставщик"
     , d2.group_no as "Отдел_2"
     , val2.uda_value_desc as "Гамма_2"
     , gtin.dim_object as "Уровень"
from rms_p009qtzb_rms_ods.v_item_master im
inner join (select item, gtin, supplier, dim_object from rms_p009qtzb_rms_ods.v_xxlm_item_supp_gtin where dim_object = 'CA' or dim_object = 'IN') gtin on gtin.gtin = im.item
left join (select dept, group_no from rms_p009qtzb_rms_ods.v_deps where is_actual='1') d on d.dept = im.dept
left join (select item, dept from rms_p009qtzb_rms_ods.v_item_master where is_actual='1') im2 on im2.item = gtin.item
left join (select dept, group_no from rms_p009qtzb_rms_ods.v_deps where is_actual='1') d2 on d2.dept = im2.dept
left join (select item,uda_value, uda_id  from rms_p009qtzb_rms_ods.v_uda_item_lov where is_actual = '1' and uda_id = 5) gamma1 on gamma1.item = im.item_parent
left join (select uda_id, uda_value, uda_value_desc from rms_p009qtzb_rms_ods.v_uda_values where is_actual = '1') val1 on gamma1.uda_value = val1.uda_value and gamma1.uda_id = val1.uda_id
left join (select item,uda_value, uda_id from rms_p009qtzb_rms_ods.v_uda_item_lov where is_actual = '1' and uda_id = 5) gamma2 on gamma2.item = im2.item
left join (select uda_id, uda_value, uda_value_desc from rms_p009qtzb_rms_ods.v_uda_values where is_actual = '1') val2 on gamma2.uda_value = val2.uda_value and gamma2.uda_id = val2.uda_id
where im.is_actual = '1' and im.item_number_type = 'EAN13'
and im.item_parent <> gtin.item