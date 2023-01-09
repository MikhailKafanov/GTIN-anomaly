select isg1.item as "ЛМ_1"
     , d1.group_no as "Отдел_1"
     , isg1.supplier as "Поставщик_1"
     , isg2.item as "ЛМ_2"
     , d2.group_no as "Отдел_2"
     , isg2.supplier as "Поставщик_2"
     , isg2.gtin as "GTIN"
from rms_p009qtzb_rms_ods.v_xxlm_item_supp_gtin isg1
inner join (select item, gtin, supplier  from rms_p009qtzb_rms_ods.v_xxlm_item_supp_gtin where dim_object = 'CA' and is_actual = '1') isg2 on isg1.gtin = isg2.gtin
left join (select item, dept from rms_p009qtzb_rms_ods.v_item_master where is_actual='1') im1 on im1.item = isg1.item
left join (select dept, group_no from rms_p009qtzb_rms_ods.v_deps where is_actual='1') d1 on d1.dept = im1.dept
left join (select item, dept from rms_p009qtzb_rms_ods.v_item_master where is_actual='1') im2 on im2.item = isg2.item
left join (select dept, group_no from rms_p009qtzb_rms_ods.v_deps where is_actual='1') d2 on d2.dept = im2.dept
where isg1.item <> isg2.item and isg1.is_actual = '1'