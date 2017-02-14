--Rune.lua
--
--========================================================================
--符文属性管理
-- rune:
-- int id
-- int lv
-- int resid
-- int exp
--
-- page:
-- [pid]
-- [1-22]
-- slot
-- id
Rune = 
{
	runeList = {},
	runePage = {},
	attribute = {},
	enemyRuneAttribute = {},
}

local attribute_list = 
{
	[1] = 2,
	[2] = 3,
	[3] = 4,
	[4] = 5,
	[5] = 6,
	[100] = 2,
	[101] = 2,
	[102] = 2,
	[103] = 2,
	[104] = 2,
	[200] = 3,
	[201] = 3,
	[202] = 3,
	[203] = 3,
	[204] = 3,
}

function Rune:Init(rune_list_, rune_page_)
	self:load_rune_list(rune_list_);
	self:load_rune_page(rune_page_);
	self:load_list_content();
end

function Rune:load_rune_list(rune_list_)
	self.runeList = rune_list_;
end

function Rune:load_rune_page(rune_page_)
	self.runePage = {};
	for k, pageInfo in pairs(rune_page_) do
		self.runePage[tonumber(k)] = {};
		for k1, v in pairs(pageInfo.page_info) do
			self.runePage[tonumber(k)][tonumber(k1)] = {slot = tonumber(k1), id = tonumber(v)};
		end
	end
	for _, page in pairs(self.runePage) do
		for i=1, 22 do
			if not page[i] then
				page[i] = {slot = i, id = -1};
			end
		end
	end
end

function Rune:load_list_content()
	self.attribute = {};

	self.attribute["quality"] = {};
	self.attribute["quality"][1] = LANG_RUNE_LIST_CONTENT_QUALITY_1; 
	self.attribute["quality"][2] = LANG_RUNE_LIST_CONTENT_QUALITY_3; 
	self.attribute["quality"][3] = LANG_RUNE_LIST_CONTENT_QUALITY_2; 

	self.attribute["attribute"] = {};
	self.attribute["attribute"][1] = {};
	self.attribute["attribute"][1][1] = LANG_RUNE_LIST_CONTENT_ATTRIBUTE_1;
	self.attribute["attribute"][1][2] = LANG_RUNE_LIST_CONTENT_ATTRIBUTE_2;
	self.attribute["attribute"][1][3] = LANG_RUNE_LIST_CONTENT_ATTRIBUTE_3;
	self.attribute["attribute"][1][4] = LANG_RUNE_LIST_CONTENT_ATTRIBUTE_4;
	self.attribute["attribute"][1][5] = LANG_RUNE_LIST_CONTENT_ATTRIBUTE_5;
	self.attribute["attribute"][1][6] = LANG_RUNE_LIST_CONTENT_ATTRIBUTE_6;

	self.attribute["attribute"][2] = {};
	self.attribute["attribute"][2][1] = LANG_RUNE_LIST_CONTENT_ATTRIBUTE_1;
	self.attribute["attribute"][2][2] = LANG_RUNE_LIST_CONTENT_ATTRIBUTE_7;
	self.attribute["attribute"][2][3] = LANG_RUNE_LIST_CONTENT_ATTRIBUTE_8;

	self.attribute["attribute"][3] = {};
	self.attribute["attribute"][3][1] = LANG_RUNE_LIST_CONTENT_ATTRIBUTE_1;

	self.attribute["status"] = {};
	self.attribute["status"][1] = LANG_RUNE_LIST_CONTENT_STATUS_1;
	self.attribute["status"][2] = LANG_RUNE_LIST_CONTENT_STATUS_2;
end

function Rune:GetAttributeInfo(type_, att_)
	if att_ == 1 then
		return self.attribute["status"];
	elseif att_ == 2 then
		return self.attribute["quality"];
	elseif att_ == 3 then
		return self.attribute["attribute"][type_];
	end
end

-- fight sys
function Rune:GetValueByRidAid(presid, attributeid)
	local role;
	local pid = nil;
	if ActorManager:IsMainHero(presid) then
		pid = 0;
	else
		role = ActorManager:GetRoleFromResid(presid);
		if role then
			pid = role.pid;
		else
			return 0;
		end
	end
	if self.runePage[pid] then
		local sum = 0;
		for i=11, 20 do
			local rune_id = self.runePage[pid][i].id;
			if rune_id ~= -1 then
				local rune = self:GetRuneById(rune_id);
				local runeData = resTableManager:GetRowValue(ResTable.rune, tostring(rune.resid*100+rune.lv));
				if runeData['attribute'] == attributeid then
					sum = sum + runeData['value'];
				end
			end
		end
		if attributeid >= 100 and attributeid <= 104 then
			return 0 - sum;
		elseif attributeid >= 200 and attributeid <= 204 then
			return sum;
		end
	else
		return 0;
	end
end

function Rune:GetEValueByRidAid(presid, attributeid)
	if self.enemyRuneAttribute == {} then
		return 0;
	end
	if self.enemyRuneAttribute[presid] then
		if self.enemyRuneAttribute[presid][attributeid] then
			if attributeid >= 100 and attributeid <= 104 then
				return 0 - self.enemyRuneAttribute[presid][attributeid];
			elseif attributeid >= 200 and attributeid <= 204 then
				return self.enemyRuneAttribute[presid][attributeid];
			end
		else
			return 0;
		end
	else
		return 0;
	end
end

function Rune:InitEnemyAttribute(data)
	self.enemyRuneAttribute = {};
	for _, role in pairs(data) do
		self.enemyRuneAttribute[role.resid] = {};
		local pro = role.pro;
		for i=1, 5 do
			self.enemyRuneAttribute[role.resid][100+i-1] = pro.pd[i];
			self.enemyRuneAttribute[role.resid][200+i-1] = pro.pa[i];
		end
	end
end

function Rune:InitEnemyAttributeByArr(data)
	self.enemyRuneAttribute = {};
	for _, role in pairs(data) do
		self.enemyRuneAttribute[role.resid] = {};
		local pro = role.pro;
		self.enemyRuneAttribute[role.resid][100] = pro.p1_d or 0;
		self.enemyRuneAttribute[role.resid][101] = pro.p2_d or 0;
		self.enemyRuneAttribute[role.resid][102] = pro.p3_d or 0;
		self.enemyRuneAttribute[role.resid][103] = pro.p4_d or 0;
		self.enemyRuneAttribute[role.resid][104] = pro.p5_d or 0;
		self.enemyRuneAttribute[role.resid][200] = pro.p1_a or 0;
		self.enemyRuneAttribute[role.resid][201] = pro.p2_a or 0;
		self.enemyRuneAttribute[role.resid][202] = pro.p3_a or 0;
		self.enemyRuneAttribute[role.resid][203] = pro.p4_a or 0;
		self.enemyRuneAttribute[role.resid][204] = pro.p5_a or 0;
	end
end

function Rune:ClearEnemyAttribute()
	self.enemyRuneAttribute = {};
end

-- Rune manager
function Rune:GetRuneInfoByTypeAndPid(type_, pid_, state_, quality_, attribute_)
	local rune_table = {};
	local rune_type_table = {};
	for _, rune in pairs(self.runeList) do
		local can_push = true;
		if self.runePage[pid_] then
			for _, slot in pairs(self.runePage[pid_]) do
				if slot.id == rune.id then
					can_push = false;
					break;
				end
			end
		end
		if type_ ~= -1 then
			local runeType = resTableManager:GetValue(ResTable.rune, tostring(rune.resid*100+rune.lv), 'type');
			if (runeType ~= type_) then
				can_push = false;
			end
		end

		if state_ == 1 then
			if rune.exp == 0 then
				can_push = false;
			end
		elseif state_ == 2 then
			if rune.exp > 0 then
				can_push = false;
			end
		end

		local runeQuality = resTableManager:GetValue(ResTable.rune, tostring(rune.resid*100+rune.lv), 'quality');
		if quality_ == 1 then
		elseif quality_ == 2 then
			if runeQuality <= 3 then
				can_push = false;
			end
		elseif quality_ == 3 then
			if runeQuality > 3 then
				can_push = false;
			end
		end

		local runeAttribute = resTableManager:GetValue(ResTable.rune, tostring(rune.resid*100+rune.lv), 'attribute');
		if attribute_ == 1 then
		else
			if attribute_list[runeAttribute] ~= attribute_ then
				can_push = false;
			end
		end

		if can_push then
			if state_ == 1 then
				table.insert(rune_table, {id = rune.id, resid = rune.resid, lv = rune.lv, exp = rune.exp, num = 1});
			elseif state_ == 2 then
				if not rune_type_table[rune.resid] then
					table.insert(rune_table, {id = rune.id, resid = rune.resid, lv = rune.lv, exp = rune.exp, num = 1});
					rune_type_table[rune.resid] = 1;
				else
					rune_type_table[rune.resid] = rune_type_table[rune.resid] + 1;
					for _, runeItem in pairs(rune_table) do
						if runeItem.resid == rune.resid then
							runeItem.num = rune_type_table[rune.resid];
							break;
						end
					end
				end
			end
		end
	end
	self:sort_rune_list(rune_table);
	return rune_table;
end

function Rune:GetRuneInfoByTypeAll(type_)
	local rune_table = {};
	for _, rune in pairs(self.runeList) do
		if (type_ == -1) then
			table.insert(rune_table, rune);
		else
			local runeType = resTableManager:GetValue(ResTable.rune, tostring(rune.resid*100+rune.lv), 'type');
			if (runeType == type_) then
				table.insert(rune_table, rune);
			end
		end
	end
	self:sort_rune_list(rune_table);
	return rune_table;
end

function Rune:GetRunePageInfoByPid(pid_)
	if self.runePage[pid_] then
		return self.runePage[pid_];
	end
	return nil;
end

function Rune:GetRuneById(id_)
	for _, rune in pairs(self.runeList) do
		if rune.id == id_ then
			return rune;
		end
	end
end

function Rune:getSameResidRune(rune_id, main_pos, mat_pos)
	local runeItem = self:GetRuneById(rune_id);
	local find = false;
	local aim_rune_id;
	for _, rune in pairs(self.runeList) do
		if rune.resid == runeItem.resid and rune.exp == 0 and rune.id ~= main_pos and self:CanMat(rune.id) then
			local find_p = false;
			for _, pos in pairs(mat_pos) do
				if rune.id == pos then
					find_p = true;
					break;
				end
			end
			if not find_p then
				find = true;
				aim_rune_id = rune.id;
				break;
			end
		end
	end
	if find then
		return aim_rune_id;
	else
		return rune_id;
	end
end

function Rune:GetBlankPos(pid, rune)
	local runeType = resTableManager:GetValue(ResTable.rune, tostring(rune.resid*100+rune.lv), 'type');
	local aim_pos = -1;
	local slot_num = (runeType == 3) and 2 or 10;
	for i=1, slot_num do
		local blank_pos = (runeType-1)*10+i;
		if self.runePage[pid] and self.runePage[pid][blank_pos] and self.runePage[pid][blank_pos].id == -1 then
			aim_pos = blank_pos;
			break;
		end
	end
	if aim_pos == -1 then
		return aim_pos;
	end
	-- is lv enough
	local lv_cur = ActorManager:GetRole(pid).lvl.level;
	local type_ = math.floor((aim_pos-1)/10) + 1;
	local pos = aim_pos - (type_-1)*10;
	local lv_req = resTableManager:GetValue(ResTable.rune_unlock, tostring(type_*100+pos), 'lv');
	if lv_cur < lv_req then
		return -2;
	end	
	
	return aim_pos;
end

function Rune:AddRuneToPage(itemid_, pid_, pagepos_)
	local msg = {};
	msg.id = itemid_;
	msg.pid = pid_;
	msg.pos = pagepos_;
	Network:Send(NetworkCmdType.req_new_rune_inlay_t,msg);
end

function Rune:inlayCallBack(msg)
	-- rune page
	if self.runePage[msg.pid] and self.runePage[msg.pid][msg.pos] then
		self.runePage[msg.pid][msg.pos].id = msg.id;
	end
end

function Rune:RemoveRuneFromPage(pid_, pagepos_)
	local msg = {};
	msg.pid = pid_;
	msg.pos = pagepos_;
	Network:Send(NetworkCmdType.req_new_rune_unlay_t,msg);
end

function Rune:unlayCallBack(msg)
	-- rune page
	if self.runePage[msg.pid] and self.runePage[msg.pid][msg.pos] then
		self.runePage[msg.pid][msg.pos].id = -1;
	end
end

-- get new rune
function Rune:getNewRune(msg_)
	for _, id in pairs(msg_.id_list) do
		table.insert(self.runeList, {id=id, lv=msg_.lv, resid=msg_.resid, exp=msg_.exp});
	end
end

function Rune:runeLevelup(main_rune, mat_list)
	local msg = {};
	msg.rune = main_rune;
	msg.mat_list = mat_list;
	Network:Send(NetworkCmdType.req_new_rune_levelup_t,msg);
end

function Rune:levelupCallBack(msg)
	for _, rune in pairs(self.runeList) do
		if rune.id == msg.id then
			rune.exp = msg.exp;
		end
	end
end

function Rune:composeRune(rune_id, req_list)
	local msg = {};
	msg.id = rune_id;
	msg.mat_list = req_list;
	table.insert(msg.mat_list, -1);
	Network:Send(NetworkCmdType.req_new_rune_compose_t, msg);
end

function Rune:composeCallBack(msg)
	for _, rune in pairs(self.runeList) do
		if rune.id == msg.id then
			rune.lv = msg.lv;
		end
	end
end

function Rune:delRune(msg)
	for _, rune_id in pairs(msg.id_list) do
		for i=table.getn(self.runeList), 1, -1 do
			if self.runeList[i].id == rune_id then
				table.remove(self.runeList, i);
				break;
			end
		end
	end
end

function Rune:active(pid)
	local msg = {};
	msg.pid = pid;
	Network:Send(NetworkCmdType.req_new_rune_active_t, msg);
end

function Rune:activeCallBack(pid)
	if not self.runePage then
		self.runePage = {};
	end
	self.runePage[pid] = {};
	for i=0, 22 do
		if not self.runePage[pid][i] then
			self.runePage[pid][i] = {slot = i, id = -1};
		end
	end
end

function Rune:GetAllType()
	return attribute_list;
end

function Rune:GetPidAttribute(pid, type_)
	local sum = 0;
	for i=1, 22 do
		if self.runePage[pid] and self.runePage[pid][i] and self.runePage[pid][i].id > 0 then
			local runeInfo = self:GetRuneById(self.runePage[pid][i].id);
			local runeData = resTableManager:GetRowValue(ResTable.rune, tostring(runeInfo.resid*100+runeInfo.lv));
			if type_ == runeData['attribute'] then
				sum = sum + runeData['value'];
			end
		end
	end
	return sum;
end

function Rune:checkMaxLv(runeItem)
	local runeExp = resTableManager:GetValue(ResTable.rune, tostring(runeItem.resid*100+runeItem.lv), 'exp');
	if runeExp == 0 then
		return true;
	end
	return false;
end

function Rune:CanMat(id)
	local can_mat = true;
	local pid=-1;
	if self.runePage then
		for k, pageInfo in pairs(self.runePage) do
			for k1, v in pairs(pageInfo) do
				if v.id == id then
					pid = k;
					can_mat = false;
					break;
				end
			end
			if not can_mat then
				break;
			end
		end
	end
	return can_mat, pid;
end

function Rune:GetSameRune(id)
	local table_same_rune = {};
	local runeItem = self:GetRuneById(id);
	for _, rune in pairs(self.runeList) do
		if rune.resid == runeItem.resid and rune.id ~= runeItem.id and self:CanMat(rune.id) then
			table.insert(table_same_rune, rune);
		end
	end
	return table_same_rune;
end

function Rune:sort_rune_list(rune_list)
	table.sort(rune_list, function(rune_a, rune_b)
		local runeDataA = resTableManager:GetRowValue(ResTable.rune, tostring(rune_a.resid*100+rune_a.lv));
		local runeDataB = resTableManager:GetRowValue(ResTable.rune, tostring(rune_b.resid*100+rune_b.lv));
		if runeDataA['quality'] > runeDataB['quality'] then
			return true;
		elseif runeDataA['quality'] == runeDataB['quality'] then
			if rune_a.lv > rune_b.lv then
				return true;
			elseif rune_a.lv == rune_b.lv then
				if rune_a.exp > rune_b.exp then
					return true;
				elseif rune_a.exp == rune_b.exp then
					if rune_a.resid < rune_b.resid then
						return true;
					else
						return false;
					end
				else
					return false;
				end
			else
				return false;
			end
		else
			return false;
		end
	end);
end

function Rune:getMatofLack(mat_pos_list, main_id, exp_require)
	local rune_table = {};
	for lv=0, 10 do
		for quality=1, 3 do
			for _, rune in pairs(self.runeList) do
				local runeData = resTableManager:GetRowValue(ResTable.rune, tostring(rune.resid*100+rune.lv));
				if lv==0 then
					if rune.exp == 0 and runeData['quality'] == quality then
						table.insert(rune_table, rune);
					end
				else
					if rune.lv == lv and runeData['quality'] == quality then
						table.insert(rune_table, rune);
					end
				end
				if table.getn(rune_table) >= 5 then
					break;
				end
			end
			if table.getn(rune_table) >= 5 then
				break;
			end
		end
		if table.getn(rune_table) >= 5 then
			break;
		end
	end

	table.sort(rune_table, function(rune_a, rune_b)
		local runeDataA = resTableManager:GetRowValue(ResTable.rune, tostring(rune_a.resid*100+rune_a.lv));
		local runeDataB = resTableManager:GetRowValue(ResTable.rune, tostring(rune_b.resid*100+rune_b.lv));
		if rune_a.lv < rune_b.lv then
			return true;
		elseif rune_a.lv == rune_b.lv then
			if runeDataA['quality'] < runeDataB['quality'] then
				return true;
			else
				return false;
			end
		else
			return false;
		end
	end)

	for i=1, 5 do
		if mat_pos_list[i] == -1 then
			for j=1, table.getn(rune_table) do
				local can_mat = true;
				for pos, id in pairs(mat_pos_list) do
					if (id ~= -1) and rune_table[j].id == id then
						can_mat = false;
						break;
					end
				end
				if rune_table[j].id == main_id then
					can_mat = false;
				end
				if not self:CanMat(rune_table[j].id) then
					can_mat = false;
				end
				if can_mat then
					mat_pos_list[i] = rune_table[j].id;
					break;
				end
			end
			local mat_rune = Rune:GetRuneById(mat_pos_list[i]);
			local rune_base_exp = resTableManager:GetValue(ResTable.rune, tostring(mat_rune.resid*100+mat_rune.lv), 'base_exp');
			exp_require = exp_require - (rune_base_exp + mat_rune.exp);
			if exp_require <= 0 then
				break;
			end
		end
	end
end
