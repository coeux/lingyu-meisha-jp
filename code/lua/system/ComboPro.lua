--========ComboPro=======================
ComboPro = 
{
	c1_exp = 0;
	c2_exp = 0;
	c3_exp = 0;
	c4_exp = 0;
	c5_exp = 0;
	c1_level = 0,
	c2_level = 0,
	c3_level = 0,
	c4_level = 0,
	c5_level = 0,
	combo_d_down = 0,
	combo_r_down = 0,
	combo_d_up = 0,
	combo_r_up = 0,
	combo_anger = {},
	combo_d_down_e = 0,
	combo_r_down_e = 0,
	combo_d_up_e = 0,
	combo_r_up_e = 0,
	combo_anger_e = {},
	item = {},
}

local name_table = {
	[1] = 'c1_level',
	[2] = 'c2_level',
	[3] = 'c3_level',
	[4] = 'c4_level',
	[5] = 'c5_level',
}

local value_table = {
	[1] = 'combo_d_down',
	[2] = 'combo_r_down',
	[3] = 'combo_d_up',
	[4] = 'combo_r_up',
	[5] = 'combo_anger',
}


function ComboPro:init()
	ActorManager.user_data.functions.combo_pro = listener(ActorManager.user_data.functions.combo_pro, Listener, Listener.ComboPro);
	self:reGenAttribute();
end

function ComboPro:reGenAttribute()
	self.combo_d_down = 0;
	self.combo_r_down = 0;
	self.combo_d_up = 0;
	self.combo_r_up = 0;
	self.combo_anger = {};
	for i=1, 5 do
		self.item[i] = {};
	end
	for i=1, 5 do
		local id = i*1000+ComboPro[name_table[i]];
		local id_begin = i*1000;
		for id_i=id_begin, id do
			local data = resTableManager:GetRowValue(ResTable.artifact_levelup, tostring(id_i));
			data['attribute'] = data['attribute'] or {};
			for _, v in pairs(data['attribute']) do
				local type_a = v[1];
				if type_a == 1 then
					self.combo_d_down = self.combo_d_down + v[2];
					if self.item[i].combo_d_down then
						self.item[i].combo_d_down = self.item[i].combo_d_down + v[2];
					else
						self.item[i].combo_d_down = v[2];
					end
				elseif type_a == 2 then
					self.combo_r_down = self.combo_r_down + v[2];
					if self.item[i].combo_r_down then
						self.item[i].combo_r_down = self.item[i].combo_r_down + v[2];
					else
						self.item[i].combo_r_down = v[2];
					end
				elseif type_a == 3 then
					self.combo_d_up = self.combo_d_up + v[2];
					if self.item[i].combo_d_up then
						self.item[i].combo_d_up = self.item[i].combo_d_up + v[2];
					else
						self.item[i].combo_d_up = v[2];
					end
				elseif type_a == 4 then
					self.combo_r_up = self.combo_r_up + v[2];
					if self.item[i].combo_r_up then
						self.item[i].combo_r_up = self.item[i].combo_r_up + v[2];
					else
						self.item[i].combo_r_up = v[2];
					end
				elseif type_a == 5 then
					if self.combo_anger[v[2]] then
						self.combo_anger[v[2]] = self.combo_anger[v[2]] + v[3];
					else
						self.combo_anger[v[2]] = v[3];
					end
					if not self.item[i].combo_anger then
						self.item[i].combo_anger = {};
					end
					if self.item[i].combo_anger[v[2]] then
						self.item[i].combo_anger[v[2]] = self.item[i].combo_anger[v[2]] + v[3];
					else
						self.item[i].combo_anger[v[2]] = v[3];
					end
				end
			end
		end
	end
end

function ComboPro:getAttributebyType(type_id_)
	return self.item[type_id_];
end

function ComboPro:getAttributebyAttibute(a_id_)
	if a_id_ == 1 then
		return self.combo_d_down;
	elseif a_id_ == 2 then
		return self.combo_r_down;
	elseif a_id_ == 3 then
		return self.combo_d_up;
	elseif a_id_ == 4 then
		return self.combo_r_up;
	elseif a_id_ == 5 then
		return self.combo_anger;
	end
	return 0;
end

function ComboPro:getAttributebyAttibute_e(a_id_)
	if a_id_ == 1 then
		return self.combo_d_down_e;
	elseif a_id_ == 2 then
		return self.combo_r_down_e;
	elseif a_id_ == 3 then
		return self.combo_d_up_e;
	elseif a_id_ == 4 then
		return self.combo_r_up_e;
	elseif a_id_ == 5 then
		return self.combo_anger_e;
	end
	return 0;
end

function ComboPro:getAttributebylevel(type_id_, level_)
	local max_level = resTableManager:GetValue(ResTable.artifact, tostring(type_id_), "max_level");
	local table_attribute = {};
	if level_ < max_level then
		local data = resTableManager:GetRowValue(ResTable.artifact_levelup, tostring(type_id_*1000+level_+1));
		for k, v in pairs(data['attribute']) do
			local t1={};
			for k1, v1 in pairs(v) do
				t1[k1] = v1;
			end
			table_attribute[k] = t1;
		end
	end
	return table_attribute;
end

function ComboPro:InitEnemyData(enemy_data)
	if not enemy_data then
		ComboPro:ClearEnemyData()
		return;
	end
	self.combo_d_down_e = enemy_data.combo_d_down;
	self.combo_r_down_e = enemy_data.combo_r_down;
	self.combo_d_up_e = enemy_data.combo_d_up;
	self.combo_r_up_e = enemy_data.combo_r_up;
	self.combo_anger_e = enemy_data.combo_anger;
end

function ComboPro:ClearEnemyData()
	self.combo_d_down_e = 0;
	self.combo_r_down_e = 0;
	self.combo_d_up_e = 0;
	self.combo_r_up_e = 0;
	self.combo_anger_e = {};
end
