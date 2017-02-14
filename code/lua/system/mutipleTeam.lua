--mutipleTeam.lua

--========================================================================
--多队伍类
--

MutipleTeam =
{
	teamList = {}; -- 队伍列表
	teamCount = 0; -- 队伍个数
	skillList = {}; -- 技能list
	default_team_id = 1; --默认队伍ID
};

--局部变量
local isInitData = false;
--初始化数据
function MutipleTeam:InitData(teamData)
	--仅刷新一个队伍（目前只有一个队伍）
	--若重构后不好使，请查看之前的commit，原有代码好使
	isInitData = true;
	for k, team in pairs(teamData) do
		self.teamList[team.tid] = {};
		self.teamList[team.tid][1] = team.pid1;
		self.teamList[team.tid][2] = team.pid2;
		self.teamList[team.tid][3] = team.pid3;
		self.teamList[team.tid][4] = team.pid4;
		self.teamList[team.tid][5] = team.pid5;
		self.teamList[team.tid].is_default = team.is_default;
		self.teamList[team.tid].tid = team.tid;
		self.teamList[team.tid].name = team.name or tostring(team.tid);
		self.teamCount = self.teamCount + 1;
		if team.is_default == 1 then
			self.default_team_id = team.tid;
		end
	end
	--local td = {tid = 1; team = teamData;};
	--self:RefreshComboMark(td);
end

--增加队伍数据
function MutipleTeam:appendTeamData(team)
end

--获取多队伍列表
function MutipleTeam:FetchMutipleList(msg)
end

--增加队伍
function MutipleTeam:AddTeamList(team)
end

--队伍调整
function MutipleTeam:AdjustTeam(teamData)
	--仅刷新一个队伍（目前只有一个队伍）
	--[[
	self:RefreshComboMark(teamData);
	self.teamList[teamData.tid] = nil;
	self.teamList[teamData.tid] = teamData.team;
	--]]
end

--获取排序好的队伍列表
function MutipleTeam:getSortMutipleTeamList()
end

--刷新一个队伍可combo状态
--teamData = {
--  tid = 队伍id;
--  team = teamList; 队伍list[5个]
--}
function MutipleTeam:RefreshComboMark(teamData)
	--"team":[37,93,91,86,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1],
	
	local comboMap = {}; -- 记录每一个combo技能的触发状态所对应的多种结果状态
	local canComboTid = 'canCombo' .. teamData.tid;

	--将该队伍中的每个角色的每个可进入combo中的技能提取出来
	for _, pid in ipairs(teamData.team) do
		if pid >= 0 then -- 非负为伙伴pid, 0-主角; -1 未放置，-2 未开启
			local actor = ActorManager:GetRole(pid);
			actor[canComboTid] = nil; -- 清除伙伴在该队伍的原有状态（防止卸下伙伴后为清除该标记）
			for k, v in ipairs(actor.skls) do -- 将伙伴的每个技能的combo触发技和结果放入comboMap中
				local s = self.skillList[v.resid];
				local flag = s and (s.combo_cause ~= 0 or s.combo_result ~= 0) or false; -- 是否为能进入combo的技能
				if flag and comboMap[s.combo_cause] == nil then 
					comboMap[s.combo_cause] = {} 
				end;
				if flag then  -- 将该技能插入comboMap中
					local cr = {s.skill_class, s.combo_cause, s.combo_result, pid}
					table.insert(comboMap[s.combo_cause], cr);
				end;
			end
		end
	end

	--深度优先搜索
	local passed = {};
	local markCombo;
	markCombo = function(map, point, canComboTid)
		if not point then return end;
		for _, l in ipairs(point) do
			if l[3] == SkillClass.ordinarySkill then return end; -- 非combo技能不处理
			local ac = ActorManager:GetRole(l[4]);
			if ac[canComboTid] and passed[l[2]..l[3]] then return end; -- 已标记该角色并且已通过路径[触发状态，结束状态]，不处理
			ac[canComboTid], passed[l[2]..l[3]] = true, true;
			markCombo(map, map[l[3]], canComboTid); -- 深搜
		end
	end

	--标记角色在本队伍的combo状态
	markCombo(comboMap, comboMap[0], 'canCombo' .. teamData.tid);
end

function MutipleTeam:getCurrentTeam()
	return self.teamList[self.default_team_id];
end

--======================================================================================
--属性副本 本地队伍 不显示在队伍选择中
function MutipleTeam:propertyTeam(teamData)
	local td = {tid = SpecialTeam.PropertyTeam; team = teamData;};
	-- self:RefreshComboMark(td);
	self.teamList[td.tid] = nil;
	self.teamList[td.tid] = teamData;
end

function MutipleTeam:getPropertyTeam()
	return self.teamList[SpecialTeam.PropertyTeam] or {};
end

function MutipleTeam:clearPropertyTeam()
  self.teamList[SpecialTeam.PropertyTeam] = {};
end
--======================================================================================

-- 探宝队伍，不显示在队伍选择中
function MutipleTeam:treasureTeam()
end

function MutipleTeam:newTeam(tid)
	local team = {};
	team[1] = 0;
	team[2] = -1;
	team[3] = -1;
	team[4] = -1;
	team[5] = -1;
	team.is_default = 0;
	team.tid = tid;
	table.insert(self.teamList, team);
	self.teamCount = self.teamCount + 1;
end

function MutipleTeam:setDefault(tid)
	if self.default_team_id == tid then
		return;
	end
	self.default_team_id = tid;
	for _,team in pairs(self.teamList) do
		if team.tid ~= tid then
			team.is_default = 0;
		else
			team.is_default = 1;
		end
	end
	local msg = {};
	msg.tid = tid
	Network:Send(NetworkCmdType.req_change_default_team, msg, true);
end

function MutipleTeam:getDefault()
	return self.default_team_id;
end

function MutipleTeam:removeTeam(tid)
	local pos = 0;
	for k, team in pairs(self.teamList) do
		if team.tid == tid then
			pos = k;
			break;
		end
	end
	if pos ~= 0 then
		table.remove(self.teamList, pos)
	else 
		return;
	end
	self.teamCount = self.teamCount - 1;
	local msg = {}
	msg.tid = tid;
	Network:Send(NetworkCmdType.req_remove_team, msg, true);
end

function MutipleTeam:getTeam(tid)
	for k, team in pairs(self.teamList) do
		if team.tid == tid then
			return team;
		end
	end
end

function MutipleTeam:getNewTeamId()
	local minTid = 1;

	local findNewTid = false;
	while(not findNewTid) do
		findNewTid = true;
		for _, team in pairs(self.teamList) do
			if team.tid == minTid then
				minTid = minTid + 1;
				findNewTid = false;
				break;
			end
		end
	end
	return minTid;
end

function MutipleTeam:haveTeam(tid)
	local haveTeam = false;
	for k, team in pairs(self.teamList) do
		if team.tid == tid then
			haveTeam = true;
		end
	end
	return haveTeam;
end

function MutipleTeam:TeamChange(tid, team)
	--修改本地team
	for i=1, 5 do
		self.teamList[tid][i] = team[i];
	end
	if tid == self:getDefault() then
		local totalfp = 0
		for i=1, 5 do
			local pid = team[i];
			if pid ~= -1 then
				local role = ActorManager:GetRole(pid);
				totalfp = totalfp + role.pro.fp;
			end
		end
		ActorManager.user_data.fp = totalfp
		uiSystem:UpdateDataBind()
	end
	--向服务器发送通知
	local msg = {};
	msg.tid = tid;
	msg.team = team;
	Network:Send(NetworkCmdType.nt_team_change, msg, true);
end

function MutipleTeam:ChangeTeamName(tid, name)
	self.teamList[tid].name = name;

	--通知服务器 该队伍名称改变
	local msg = {};
	msg.tid = tid;
	msg.name = name;
	Network:Send(NetworkCmdType.nt_change_team_name, msg, true);
end

function MutipleTeam:GetTeamName(tid)
	return self.teamList[tid].name;
end

--获取当前默认队伍的战斗力
function MutipleTeam:GetDefaultTeamFp()
	if (not isInitData) then
		return -1;
	end
	local totalfp = 0;
	for i=1, 5 do
		local pid = self.teamList[self.default_team_id][i];
		if pid ~= -1 then
			local role = ActorManager:GetRole(pid);
			totalfp = totalfp + role.pro.fp;
		end
	end
	return totalfp;
end

function MutipleTeam:getPveTeam()
	local team = {};
	for i=1, 5 do
		team[i] = self.teamList[i];
	end
	return team;
end

function MutipleTeam:getTeamFp(tid)
	local totalfp = 0;
	for i=1, 5 do
		local pid = self.teamList[tid][i];
		if pid ~= -1 then
			local role = ActorManager:GetRole(pid);
			if role then
				local add_fp = GemPanel:reCalculateFp(role, i);
				totalfp = totalfp + add_fp;
			end
		end
	end
	return math.floor(totalfp);
end
function MutipleTeam:getTeamMemberNum(tid)
	local num = 0;
	for i=1, 5 do
		local pid = self.teamList[tid][i];
		if pid ~= -1 then
			local role = ActorManager:GetRole(pid);
			num = num + 1;
		end
	end
	return num;
end
--判断一个伙伴是否在默认队伍中
function MutipleTeam:isInDefaultTeam(rolepid)
	local in_team = false;
	for i=1, 5 do
		local pid = self.teamList[self.default_team_id][i];
		if pid ~= -1 and pid == rolepid then
			in_team = true;
			break;
		end
	end
	return in_team;
end	

function MutipleTeam:getRolePos(rolepid)
	for i=1, 5 do
		local pid = self.teamList[self.default_team_id][i];
		if pid ~= -1 and pid == rolepid then
			return i;
		end
	end
	return 1;
end	

--判断一个伙伴是否在默认队伍中
function MutipleTeam:addPartnerToDefaultTeam(rolepid)
	local role = ActorManager:GetRole(rolepid)
	if Task:getMainTaskId() < FunctionOpenTask.team then
		if role.resid ~= GuidePartner.hire1 and role.resid ~= GuidePartner.hire and role.resid ~= GuidePartner.cardrolelvup and role.resid ~= GuidePartner.love then
			return 
		end
	end
	if not role then
		return 
	end
	local isCanAdd = false;
	for i=1, 5 do
		local pid = self.teamList[self.default_team_id][i];
		if pid == rolepid then
			return;
		end
		if pid == -1 then
			isCanAdd = true
		end
	end

	if isCanAdd then
		--  加入新的英雄，更新队伍信息
		local index = 1
		for i=5, 2, -1  do
			if self.teamList[self.default_team_id][i] == -1 then       --  从后往前找，看这个位置是否有英雄，有英雄则比较当前位置和选择英雄的攻击范围，
				index = i             --  没有英雄则将选择英雄插入该位置
				break
			end

			local role_t = ActorManager:GetRole(self.teamList[self.default_team_id][i])             --  比较攻击范围
			local hit_range_t = resTableManager:GetValue(ResTable.actor, tostring(role_t.resid), 'hit_area')
			local hit_range = resTableManager:GetValue(ResTable.actor, tostring(role.resid), 'hit_area')
			if hit_range < hit_range_t then
				index = i
				break
			end
		end

		--  更新英雄位置
		if index ~= 1 then
			for i=1, index-1 do
				if self.teamList[self.default_team_id][i+1] ~= -1 then
					self.teamList[self.default_team_id][i] = self.teamList[self.default_team_id][i+1] 
				end
			end
		end
		self.teamList[self.default_team_id][index] = rolepid

		local team = {};
		for i=1, 5 do
			team[i] = tonumber(self.teamList[self.default_team_id][i]);
		end
		MutipleTeam:TeamChange(self.default_team_id, team)
		if Task:getMainTaskId() ~= 100001 then
			--Toast:MakeToast(3, Lang_AddPartnter1 .. role.name .. Lang_AddPartnter2);
			Toast:MakeToast(3, Lang_AddPartnter3);
		end
	end
end	

