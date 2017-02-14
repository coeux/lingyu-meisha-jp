--actorManager.lua

--========================================================================
--角色管理类

ActorManager =
	{
		globalActorID	= 900;				--全局角色ID
		actorList		= {};				--角色列表
		partnerIdMap	= {};
		mainCityActor   = {};
		--========================================================================

		user_data		= {};				--用户数据
		hero			= nil;				--本地英雄

		oldFP			= 0;				--记录历史战力（界面打开时）
		main_model		= 102;				--人物形象
	}

--========================================================================

--分配id
function ActorManager:allocActorID()
	self.globalActorID = self.globalActorID + 1;
	if self.globalActorID >= 1000 then
		self.globalActorID = 900;
	end

	return self.globalActorID;
end

--========================================================================
--角色管理

--创建新本地玩家
function ActorManager:CreateHero( resID, id )

	local actor = Hero.new( id, tostring(resID) );
	self.actorList[actor:GetID()] = actor;
	self.hero = actor;
	return actor;

end

-- 更改本地玩家形象
function ActorManager:ChangeHeroModel()
	local id;
	if ActorManager.main_model < 5000000 then
		id = ActorManager.main_model;
	else
		id = math.floor((ActorManager.main_model%1000000)/100);
	end
	self.hero.resID = id;
	self.hero:InitAvatar(ActorManager.main_model);
	--翅膀
	if (self.hero.wingid ~= nil) and (self.hero.wingid > 0) then
		local before_wingid = self.hero.wingid;
		self.hero:DettachWing();
		self.hero:AttachWing(before_wingid);
	end

	local x = math.random(50);
	local y = math.random(50);
	local pos = Vector2(math.floor(x), math.floor(y));
	self.hero:MoveTo(pos);
end

--创建新玩家
function ActorManager:CreatePlayer( resID, id  )

	local actor = Player.new( id, tostring(resID) );
	self.actorList[actor:GetID()] = actor;
	table.insert(self.mainCityActor,actor)
	return actor;
end


--创建新玩家
function ActorManager:CreateScufflePlayer( resID, id  )

	local actor = ScufflePlayer.new( id, tostring(resID) );
	self.actorList[actor:GetID()] = actor;
	return actor;

end


--创建新剧情里的NPC
function ActorManager:CreatePlotNPC(id,  resID )

	local actor = NPC.new( id, tostring(resID) );
	self.actorList[actor:GetID()] = actor;
	return actor;

end

--创建新NPC
function ActorManager:CreateNPC( resID )

	local actor = NPC.new( resID, tostring(resID) );
	self.actorList[actor:GetID()] = actor;
	return actor;

end

--创建新的CityBoss，杀星系统
function ActorManager:CreateCityBoss( resID, orderId, posx, posy)
	local actor = CityBoss.new( resID, tostring(resID), orderId );
	actor.posx = posx;
	actor.posy = posy;
	self.actorList[actor:GetID()] = actor;
	return actor;
end

--创建红包，公会系统
function ActorManager:CreateRedEnvelopes( id )
	local actor = RedEnvelopes.new( id, tostring(Configuration.RedEnvelopesResID) );
	self.actorList[actor:GetID()] = actor;
	return actor;
end

--创建战斗者(英雄)
function ActorManager:CreatePFighter( resID , is_enemy)

	local actor = Fighter_Player.new( self:allocActorID(), tostring(resID), is_enemy );
	self.actorList[actor:GetID()] = actor;
	return actor;

end

--创建第一场战斗的本方角色
function ActorManager:CreateNPFighter(resID)

	local actor = Fighter_Novice_Player.new( self:allocActorID(), tostring(resID) );
	self.actorList[actor:GetID()] = actor;
	return actor;

end

--创建战斗者(怪物)
function ActorManager:CreateMFighter( resID, monsterData )

	local actor = Fighter_Monster.new( self:allocActorID(), tostring(resID), monsterData );
	self.actorList[actor:GetID()] = actor;
	return actor;

end

--创建怪物Boss
function ActorManager:CreateBFigher( resID, monsterData)

	local actor = Fighter_Boss.new( self:allocActorID(), tostring(resID), monsterData );
	self.actorList[actor:GetID()] = actor;
	return actor;

end

--销毁角色
function ActorManager:DestroyActor( id )
	self.actorList[id] = nil;
end
function ActorManager:DestroyMainCityActor(id)
	local count = 1
	for _,player in pairs(self.mainCityActor) do
		if player.id == id then
			table.remove(self.mainCityActor,count)
			break
		end
		count = count + 1
	end
end
--查找角色
function ActorManager:GetActor( id )
	return self.actorList[id];
end

--========================================================================
--功能函数

--调整服务器发来的角色的数据
function ActorManager:AdjustRoleData()
	--新增一个openRoundId，表示已打开的关卡
	self.user_data.round.openRoundId = self.user_data.round.roundid;
	ActorManager.user_data.powerProgress = self.user_data.power;

	local count = 1 + #self.user_data.partners;
	for index = 1, count do
		local role = {};
		if 1 == index then
			role = self.user_data.role;
			role.name = ActorManager.user_data.name;
		else
			role = self.user_data.partners[index - 1];
		end

		self.partnerIdMap[role.resid] = true;

		--设置队伍
		role.teamIndex = -1;
		role.fellowIndex = -1;

		--调整角色
		self:AdjustRole(role);
		--调整角色技能
		self:AdjustRoleSkill(role);
		--调整经验
		self:AdjustRoleLevel(role, role.lvl);
		--调整属性
		self:AdjustRolePro(role.job, role.pro, role.pro);

		--调整装备
		self:AdjustRoleEquip( role )
	end

	local fellowList = {};
	for index = 11, 16 do
		table.insert(fellowList, self.user_data.team[index]);
	end
	self.user_data.fellow = fellowList;

	local teamList = {};
	for index = 1, 5 do
		table.insert(teamList, self.user_data.team[index]);
	end
	self.user_data.team = teamList;

	for _, partner in pairs(self.user_data.partners) do
		partner.teamIndex = 0;
	end

	--设置队伍索引
	for k, team in ipairs(self.user_data.team)  do
		if team.is_default == 1 then
			if team.pid1 > -1 then
				local role = self:GetRole(team.pid1);
				role.teamIndex = 1;
			end
			if team.pid2 > -1 then
				local role = self:GetRole(team.pid2);
				role.teamIndex = 1;
			end
			if team.pid3 > -1 then
				local role = self:GetRole(team.pid3);
				role.teamIndex = 1;
			end
			if team.pid4 > -1 then
				local role = self:GetRole(team.pid4);
				role.teamIndex = 1;
			end
			if team.pid5 > -1 then
				local role = self:GetRole(team.pid5);
				role.teamIndex = 1;
			end
		end
	end

	for k, pid in ipairs(self.user_data.fellow)  do
		if pid ~= -1 and (pid ~= -2) then
			local role = self:GetRole(pid);
			role.fellowIndex = k;
		end
	end

	--调试符文初始化数据
	RuneManager:AdjustRuneData();

	--更新总战斗力
	self:UpdateFightAbility();
	self:AdjustHeroName();
end

--调整主角名字
function ActorManager:AdjustHeroName()
  --现在不需要保留此功能
  if true then
    return
  end
	if ActorManager:IsGuidStepNoDone(GuideStep.changeName) then
		UserGuideRenamePanel:setDefaultName(self.user_data.name);
		local resid = self.user_data.role.resid;
		local name = resTableManager:GetValue(ResTable.actor, tostring(resid), 'name');
		self:ChangeHeroName(name);
	end
end

--更改英雄名字
function ActorManager:ChangeHeroName(name)
	self.user_data.name = name;
	self.user_data.role.name = name;
	self.user_data.role.fullName = name;

	if self.hero ~= nil then
		self.hero:RefreshName(name);
	end
end

--添加新伙伴
function ActorManager:AddRole( role )
	table.insert(self.user_data.partners, role);
	self.partnerIdMap[role.resid] = true;
	role.teamIndex = -1;
	role.fellowIndex = -1;
	--调整角色
	self:AdjustRole(role);
	--调整角色技能
	self:AdjustRoleSkill(role);
	--调整经验
	self:AdjustRoleLevel(role, role.lvl);
	--调整属性
	self:AdjustRolePro(role.job, role.pro, role.pro);

	--调整装备
	self:AdjustRoleEquip( role )
	--调整符文
	RuneManager:AdjustRoleRuneData( role );

	--更新背包可合成英雄的数量
--	Package:UpdateAvailableHeroCount();
end

--移除伙伴
function ActorManager:RemoveRole( pid )
	for k,v in ipairs(self.user_data.partners) do
		if v.pid == pid then
			self.partnerIdMap[v.resid] = nil;
			Package:UpdateAvailableHeroCount();			--更新背包可合成英雄的数量
			table.remove(self.user_data.partners, k);
			return k + 1;	--1是主角
		end
	end
end

--调整角色数据
function ActorManager:AdjustRole( role )
	local actorData = resTableManager:GetRowValue(ResTable.actor, tostring(role.resid));
	role.actorForm = actorData['img'];

	local naviInfo;
	if role.lvl.lovelevel == LovePanel.MAX_LOVE_TASK_LEVEL then
		naviInfo = resTableManager:GetRowValue(ResTable.navi_main, tostring(role.resid + 10000));
	else
		naviInfo = resTableManager:GetRowValue(ResTable.navi_main, tostring(role.resid));
	end

	role.midImage = naviInfo['role_path_list'];
	role.headImage = naviInfo['role_path_icon'];
	role.bgImage = naviInfo['bg_path'];
	role.roleImage = naviInfo['role_path'];

	role.propertyImage = GetPicture('common/shuxing_' .. actorData['attribute'] .. '.ccz');
	role.job = actorData['job'];
	role.jobIcon = uiSystem:FindImage('chuangjianjuese_zhiye' .. role.job);

	role.attribute = actorData['attribute'];
	if nil == role.name then
		role.name = actorData['name'];
	end

	if (actorData['title'] == nil) or (actorData['title'] == '') then
		role.fullName = role.name;
		role.title = '';
	else
		role.fullName = actorData['title'] .. '·' .. role.name;
		role.title = actorData['title'];
	end

	--稀有度
	if role.pid == 0 then
		role.rare = Configuration:getRare(role.lvl.level);
	else
		role.rare = actorData['rare'];
	end

	--类型
	role.type = role.type or 1;

	--是否觉醒
	role.isAwaken = false;         --是否觉醒

	--角色恋爱度
	role.lovevalue = role.lovevalue;

	--阶数
	role.rank = role.quality or resTableManager:GetValue(ResTable.item, tostring(role.resid + 30000), 'quality');

	--技能
	if role.skls == nil then
		role.skls = {};

		local keys = {'skill_id', 'skill_id2', 'skill_id3','skill_passive','skill_passive1','skill_auto','skill_auto2','skill_auto3'};
		for _,key in pairs (keys) do
			if actorData[key] then
				local skill = {};
				skill.resid = actorData[key];
				skill.level = 1;
				table.insert(role.skls, skill);
			end
		end
	end
end

--调整角色经验数据
function ActorManager:AdjustRoleLevel(role, lvl)
	--设置角色相关经验
	local curLevelUpExp = resTableManager:GetValue(ResTable.levelup, tostring(lvl.level), 'exp');		--当前等级升级需要的总经验
	local lastLevelUpExp;				--上一等级升级需要的总经验
	if lvl.level - 1 == 0 then
		lastLevelUpExp = 0;
	else
		lastLevelUpExp = resTableManager:GetValue(ResTable.levelup, tostring(lvl.level - 1), 'exp');
	end
	if nil == curLevelUpExp then
		lvl.levelUpExp = lastLevelUpExp;
		lvl.curLevelExp = lastLevelUpExp;
		role.lvl = lvl;
		return;
	end

	lvl.curLevelExp = lvl.exp - lastLevelUpExp;
	lvl.levelUpExp = curLevelUpExp - lastLevelUpExp;
	role.lvl = lvl;

	--稀有度
	if role.pid == 0 then
		role.rare = Configuration:getRare(role.lvl.level);
	end
end

--调整角色的属性数据
function ActorManager:AdjustRolePro(job, rolePro, pro)
	--角色职业
	if (JobType.magician == job) then
		rolePro.attack = pro.mgc;
		rolePro.attackType= LANG_actorManager_1;
	else
		rolePro.attack = pro.atk;
		rolePro.attackType= LANG_actorManager_2;
	end

	rolePro.atk = pro.atk;
	rolePro.mgc = pro.mgc;

	rolePro.hp = pro.hp;
	rolePro.def = pro.def;
	rolePro.res = pro.res;
	rolePro.cri = pro.cri;
	rolePro.acc = pro.acc;
	rolePro.dodge = pro.dodge;
	rolePro.fp = pro.fp;
	rolePro.power = pro.power;

        AntiCheating:AdjustRolePro();
end

--调整翅膀的属性数据
function ActorManager:AdjustWingPro(job, roleWing, wing)
	--角色职业
	if (JobType.magician == job) then
		roleWing.attack = wing.mgc;
		roleWing.mgc = wing.mgc;
	else
		roleWing.attack = wing.atk;
		roleWing.atk = wing.atk;
	end

	roleWing.hp = wing.hp;
	roleWing.def = wing.def;
	roleWing.res = wing.res;
	roleWing.cri = wing.cri;
	roleWing.acc = wing.acc;
	roleWing.dodge = wing.dodge;
	roleWing.fp = wing.fp;
	roleWing.power = wing.power;
end


--调整角色的技能数据
function ActorManager:AdjustRoleSkill( role )
	for _,skill in ipairs(role.skls) do
		skill.qualityrank = SkillStrPanel:GetrequareRank(role.resid, skill.resid)
	end
	table.sort(role.skls, function (s1, s2)
		if s1.qualityrank ~= s2.qualityrank then
			return s1.qualityrank < s2.qualityrank;
		else
			return s1.resid < s2.resid;
		end
	end);

		local sortFunc = function(a, b)
		if b.pro.fp ~= a.pro.fp then
			return b.pro.fp < a.pro.fp
		else
			return b.pid < a.pid
		end
	end

	for _,skill in ipairs(role.skls) do
		local data = resTableManager:GetRowValue(ResTable.skill, tostring(skill.resid));
		if data == nil then
			local name = resTableManager:GetValue(ResTable.passiveSkill, tostring(skill.resid), 'name');
			skill.name = name;
			skill.describe = '';
		else
			skill.name = data['name'];
			skill.describe = data['info'];
		end
	end
end

--调整角色的装备数据
function ActorManager:AdjustRoleEquip( role )
	local equipInfos = {};
	for _,equip in pairs(role.equips) do
		table.insert(equipInfos,equip)
	end
	table.sort(equipInfos,function(a,b) return a.eid < b.eid end )
	for f,equip in ipairs(equipInfos) do
		role.equips[tostring(f)]= equipInfos[f];
	end
end
--根据pid获取主角或者伙伴的数据
function ActorManager:GetRole(pid)
	if 0 == pid then
		return self.user_data.role;
	else
		for _, role in ipairs(self.user_data.partners) do
			if pid == role.pid then
				return role;
			end
		end

		return nil;
	end
end

--根据resid获取主角或者伙伴的数据
function ActorManager:GetRoleFromResid(resid)
	if self.user_data.role.resid == resid then
		return self.user_data.role;
	else
		for _, role in ipairs(self.user_data.partners) do
			if resid == role.resid then
				return role;
			end
		end

		return nil;
	end
end

--是否拥有某个伙伴
function ActorManager:IsHavePartner(resid)
	return self.partnerIdMap[resid];
end

--是否为主角
function ActorManager:IsMainHero(role_resid)
	if ActorManager.user_data.role.resid == (role_resid % 1000) then
		return true;
	else
		return false;
	end
end

--更新总战斗力
function ActorManager:UpdateFightAbility()
	local team_fp = MutipleTeam:GetDefaultTeamFp();
	if -1 == team_fp then
		local totalFightAbility = 0;
		for _,role in ipairs(self.user_data.partners) do
			if role.teamIndex > 0 then
				totalFightAbility = totalFightAbility + role.pro.fp;
			end
		end
		self.user_data.fp = totalFightAbility + self.user_data.role.pro.fp;
	else
		self.user_data.fp = team_fp;
	end
	uiSystem:UpdateDataBind();

	return self.user_data.fp;
end

--新手步骤没有做
function ActorManager:IsGuidStepNoDone( pos )
	return bit.band(ActorManager.user_data.userguide.isnew, bit.lshift(1, pos)) == 0;
end

--新手步骤已做
function ActorManager:IsGuidStepDone( pos )
	return bit.band(ActorManager.user_data.userguide.isnew, bit.lshift(1, pos)) ~= 0;
end

--设置功能点击
function ActorManager:SetGuidStepDone( pos )
	ActorManager.user_data.userguide.isnew = bit.bor(ActorManager.user_data.userguide.isnew, bit.lshift(1, pos));
end

--获取所有英雄的战斗力
function ActorManager:GetAllHeroFightAbility()
	local totalFightAbility = 0;
	for _,role in ipairs(self.user_data.partners) do
		totalFightAbility = totalFightAbility + role.pro.fp;
	end

	totalFightAbility = totalFightAbility + self.user_data.role.pro.fp;
	return totalFightAbility;
end

--显示获得英雄碎片
function ActorManager:ShowTipOfHeroToPiece(actorID)
	--英雄已经被拆解
	local actor = resTableManager:GetValue(ResTable.actor, tostring(actorID), {'hero_piece', 'name', 'rare'});
	local piece = resTableManager:GetValue(ResTable.item, tostring(actorID + 30000), {'name', 'quality'})

	local contents = {};
	table.insert(contents, {cType = MessageContentType.Text; text = LANG_actorManager_3});
	table.insert(contents, {cType = MessageContentType.Text; text = actor['name']; color = QualityColor[actor['rare']]});
	table.insert(contents, {cType = MessageContentType.Text; text = LANG_actorManager_4});
	table.insert(contents, {cType = MessageContentType.Text; text = piece['name']; color = QualityColor[piece['quality']]});
	table.insert(contents, {cType = MessageContentType.Text; text = '*' .. actor['hero_piece']});

	MessageBox:ShowDialog(MessageBoxType.Ok, contents);

	return (actorID + 30000), actor['hero_piece'];
end

--初始化鼓舞数据
function ActorManager:InitInspire()
	for index = 1, 3 do
		if (ActorManager.user_data.counts.n_guwu[tostring(index)] == nil) then
			ActorManager.user_data.counts.n_guwu[tostring(index)] = {progress = 0, v = 0, stamp_yb = 0, stamp_coin = 0};
		end
	end
end

function ActorManager:getRoleFromRoleList(index)
	local role = nil;
	if 1 == index then
		--主角
		role = ActorManager.user_data.role;
	else
		--伙伴
		role = ActorManager.user_data.partners[index - 1];
	end
	return role;
end

function ActorManager:getIndexFromRole(role)
	if role.resid == ActorManager.user_data.role.resid then
		return 1;
	end

	for i=1, #ActorManager.user_data.partners do
		if role.resid == ActorManager.user_data.partners[i].resid then
			return i+1;
		end
	end
end

function ActorManager:setKanbanRole(msg)
	ActorManager.user_data.role.kanban = msg.resid;
	ActorManager.user_data.role.kanban_type = msg.type;
end

function ActorManager:getKanbanRole()
	if ActorManager.user_data.role.kanban == 0 then
		local msg = {};
		msg.uid = ActorManager.user_data.uid;
		msg.resid = self.user_data.role.resid;
		msg.type = 1;
		Network:Send(NetworkCmdType.req_set_kanban_role, msg);
		return self.user_data.role.resid;
	end
	return ActorManager.user_data.role.kanban;
end

function ActorManager:getHeadImage(resid, lovelevel)
	local naviInfo;
	if lovelevel == LovePanel.MAX_LOVE_TASK_LEVEL then
		naviInfo = resTableManager:GetRowValue(ResTable.navi_main, tostring(resid + 10000));
	else
		naviInfo = resTableManager:GetRowValue(ResTable.navi_main, tostring(resid));
	end
	return GetPicture('navi/' .. naviInfo['role_path_icon'] .. '.ccz');
end

function ActorManager:GetUid()
	return ActorManager.user_data.uid;
end
function ActorManager:isPlayerPos(pos)
	local tPlayer = nil
	for _,player in pairs(self.mainCityActor) do
		if player:Hit(pos) then
			if tPlayer == nil then
				tPlayer = player
			else
				local ppos = player:GetPosition();
				local tppos = tPlayer:GetPosition();
				if ppos.y < tppos.y then
					tPlayer = player
				end
			end
		end
	end
	if tPlayer then
		return true,tPlayer;
	else
		return false;
	end
end

function ActorManager:IsPartnerChipEnough(resid)
	local enough = false;
	local piece_count = resTableManager:GetValue(ResTable.actor, tostring(resid), 'hero_piece');
	local chipId = resid + 30000;
	local chipItem = Package:GetChip(tonumber(chipId));
	if chipItem and chipItem.count >= piece_count then
		enough = true;
	end
	return enough;
end
