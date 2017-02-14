--Combo Pro
NetworkMsg_ComboPro =
{
};

function NetworkMsg_ComboPro:attributeChange(msg)
	local combo_pro = ActorManager.user_data.functions.combo_pro;
	if msg.attribute_id == 1 then
		combo_pro.c1_level = msg.value;
	elseif msg.attribute_id == 2 then
		combo_pro.c2_level = msg.value;
	elseif msg.attribute_id == 3 then
		combo_pro.c3_level = msg.value;
	elseif msg.attribute_id == 4 then
		combo_pro.c4_level = msg.value;
	elseif msg.attribute_id == 5 then
		combo_pro.c5_level = msg.value;
	end
end

function NetworkMsg_ComboPro:expChange(msg)
	local combo_pro = ActorManager.user_data.functions.combo_pro;
	if msg.attribute_id == 1 then
		combo_pro.c1_exp = msg.value;
	elseif msg.attribute_id == 2 then
		combo_pro.c2_exp = msg.value;
	elseif msg.attribute_id == 3 then
		combo_pro.c3_exp = msg.value;
	elseif msg.attribute_id == 4 then
		combo_pro.c4_exp = msg.value;
	elseif msg.attribute_id == 5 then
		combo_pro.c5_exp = msg.value;
	end
end
	
