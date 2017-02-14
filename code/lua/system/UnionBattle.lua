--UnionBattle.lua
--========================================================================
UnionBattle =
{
	partners = {};
	UnionBattleTeam = {},
	UnionBattleEnemyTeam = {},
	UnionBattleFightTeam = {},
	allyTeamList = {},
	enemyTeamList = {},
	enemyTeamMap = {};
	leaveAnger = 0; --我方怒气
	anger_enemy = 0; --敌方怒气
	buildingLevel = 0;
};
function UnionBattle:Init()
	self.UnionBattleTeam = {}
end
function UnionBattle:setUnionBattleTeam(teamData)
	self.UnionBattleTeam = {}
	self.UnionBattleTeam = teamData
	for k,v in pairs(self.UnionBattleTeam) do
		print('setUnionBattleTeam-pid->'..tostring(v.pid))
	end
end
function UnionBattle:getUnionBattleFightTeamPidList()
	
end
function UnionBattle:setUnionBattleFightTeam(teamData)
	self.UnionBattleFightTeam = {}
	self.UnionBattleFightTeam = teamData
end
function UnionBattle:getUnionBattleFightTeam()
	return self.UnionBattleFightTeam
end
function UnionBattle:getUnionBattleTeam()
	return self.UnionBattleTeam
end
function UnionBattle:getUnionBattleTeamPidList()
	local UnionBattleTeamPid = {}
	for i = 1 , 5 do
		table.insert(UnionBattleTeamPid,self.UnionBattleTeam[i].pid)
	end
	return UnionBattleTeamPid
end
function UnionBattle:GetFightPartnersPid()
	local partnerPid = {}
	local count = 0
	for k,actor in pairs(self.allyTeamList) do
		table.insert(partnerPid,actor.pid)
		count = count + 1;
	end
	for i = 1 ,5 - count do
		table.insert(partnerPid,-1)
	end
	for i = 1 ,5 do
		print('fightPartnersPid->'..tostring(partnerPid[i]))
	end
	return partnerPid
end
--function UnionBattle:reqExitUnionBattle(is_win)
--	local msg = {}
--	msg.is_win = is_win;
--end
--[[
function UnionBattle:reqExitUnionBattle1(is_win)
	local msg = {}
	msg.is_win = is_win;
	Network:Send(NetworkCmdType.req_union_battle_fight_end, msg)
end
]]
function UnionBattle:onHandlePartners(partners)
  self.partners = {};
	self.partners = partners;
	for pid,hp in pairs(self.partners) do
		print('partners-pid->'..pid..' - hp->'..tostring(hp))
	end
end
function UnionBattle:isCanPartners(pid)
	for ppid,hp in pairs(self.partners) do
		if tonumber(ppid) == pid then
			return true;
		end
	end
	return false;
end
function UnionBattle:SetAllyHP(pid,hp)
	self.partners[tostring(pid)] = hp;
	for ppid,php in pairs(self.partners) do
		print('setHp-pid->'..tostring(ppid)..' -php->'..tostring(php))
	end
--[[
	for ppid,php in pairs(self.partners) do
		if tonumber(ppid) == pid then
			self.partners[ppid] = php;
			break;
		end
	end
]]
end
function UnionBattle:updateEnemyTeamMap(enemy)
	for k,actor in pairs(self.enemyTeamMap) do
		if actor.pid == enemy.pid then
			actor.hp = enemy.hp;
		end
	end
end
function UnionBattle:reqExitUnionBattle(is_win)
	--local is_win =  self.isUnionBattleWin;
	print(debug.traceback());
	print(debug.traceback());
	print(debug.traceback());
	local msg = {};
	if is_win then
		print('gameOver-win-selfTotal->'..tostring(FightManager:getTotalAnger()))
		print('gameOver-win-selfBarTotal->'..tostring(FightUIManager.angerBar.CurValue))
		UnionBattle.leaveAnger = FightManager:getTotalAnger() + ((#FightSkillCardManager.handSkillList)
		+(#FightSkillCardManager.handSkillQueue)) * 100
		UnionBattle.anger_enemy = 0
		print('gameOver-win->'..tostring(FightManager:getTotalAnger() + ((#FightSkillCardManager.handSkillList)
		+(#FightSkillCardManager.handSkillQueue)) * 100)..' -skillListCount->'..tostring(#FightSkillCardManager.handSkillList))
	else
		print('gameOver-lose-enemyTotal->'..tostring(FightManager:getTotalEnemyAnger()))
		UnionBattle.leaveAnger = 0
		UnionBattle.anger_enemy = FightManager:getTotalEnemyAnger() + (#FightSkillCardManager.enemyHandSkillList) * 100
	end
	msg.is_win = is_win;
	msg.anger = math.floor(self.leaveAnger + 0.5);
	msg.anger_enemy = math.floor(self.anger_enemy + 0.5);
	print('reqAnger->'..tostring(msg.anger))
	print('reqangerEnemy->'..tostring(msg.anger_enemy))
	msg.partners = {}
	for _, actor in pairs(self.allyTeamList) do
		local hp = actor.hp - actor.hp % 0.0001
		actor.hp = hp;
		self:SetAllyHP(actor.pid, hp) --[[ 更新本地伙伴血量 ]]
		print('actor.pid->'..actor.pid..' -hp->'..hp)
		table.insert(msg.partners, {pid = actor.pid, hp = hp})
		
	end
	local i = 1;
	for _, enemy in pairs(self.enemyTeamList) do
		self:updateEnemyTeamMap(enemy)
	end
	
	for k,enemy in pairs(self.enemyTeamMap) do
		msg['hp'..k] = enemy.hp - enemy.hp% 0.0001
		print('enemy-k->'..k..'-hp->'..msg['hp'..k]..' -pid->'..enemy.pid);
	end
	--[[
	msg.hp1 = self.enemyTeamList[1] - self.enemyTeamList[1] % 0.0001
	msg.hp2 = self.enemyTeamList[2] - self.enemyTeamList[2] % 0.0001
	msg.hp3 = self.enemyTeamList[3] - self.enemyTeamList[3] % 0.0001
	msg.hp4 = self.enemyTeamList[4] - self.enemyTeamList[4] % 0.0001
	msg.hp5 = self.enemyTeamList[5] - self.enemyTeamList[5] % 0.0001
	]]
	print('req-enemHP1->'..tostring(msg.hp1)..' -enemHP2->'..tostring(msg.hp2)..' -enemHP3->'..tostring(msg.hp3)..' -enemHP4->'..tostring(msg.hp4)..' -enemHP5->'..tostring(msg.hp5))
	Network:Send(NetworkCmdType.req_union_battle_fight_end, msg);
	
end
function UnionBattle:HP(pid)
	local hp = 1;
	for ppid,php in pairs(self.partners) do
		if tonumber(ppid) == pid then
			hp = php;
			break;
		end
	end
	return hp;
end
function UnionBattle:EnemyHP(resid)
	local hp = 0
	__.each(self.enemyTeamList, function(e)
		if e.resid == resid then
			hp = e.hp
		end
	end)
	return hp;
end
function UnionBattle:AllyHP(resid)
	local hp = 0;
	__.each(self.allyTeamList, function(a)
		if a.resid == resid then
			hp = a.hp;
		end
	end);
	return hp;
end
function UnionBattle:FightOver()
	for _, actor in pairs(self.allyTeamList) do
		actor.hp = 0
	end
	for _, actor in pairs(self.enemyTeamList) do
		actor.hp = 0
	end
end

function UnionBattle:GetAtt()
	for k,v in pairs(UnionBattlePanel.otherBuidingLevel) do
		if tonumber(k) == UnionBuZhenPanel.buildingId then
			self.buildingLevel = v;
			break;
		end
	end
	local buildingType = resTableManager:GetValue(ResTable.guild_battle, tostring(UnionBuZhenPanel.buildingId), 'type');
	local att = resTableManager:GetValue(ResTable.guild_battle_building, tostring(tonumber(buildingType)*100+self.buildingLevel),'add_attribute');
	return att
end
--========================================================================
