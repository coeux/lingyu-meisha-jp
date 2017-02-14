--fighter_novice_player.lua
--==========================================================================
--新手战斗中的本方角色

Fighter_Novice_Player = class(Fighter);

function Fighter_Novice_Player:constructor(id, resID)
	--角色等级
	self.m_level = 1;

	--初始化角色基本数据
	self.m_propertyData:InitPlayerBaseData(true);

	--初始化新手战斗的战斗数据
	self.m_propertyData:InitNovicePlayerFightData();

	--预加载角色美术资源
	self:PreLoadAvatarResource(false, true);

	--角色入场时保持待机状态的持续时间
	self.m_keepIdleLastTime = 0;

	--初始化角色技能
	self:initSkillData();
end

--初始化角色形象（要在战斗预加载结束之后才能执行）
function Fighter_Novice_Player:InitAvatar()
	--执行父类函数
	Fighter.InitAvatar(self);

	--初始化角色形象
	self.m_avatarData:InitPlayerAvatar(true);
end

--初始化角色技能
function Fighter_Novice_Player:initSkillData()
	table.insert(self.m_skillList, FightNormalSkillClass.new(self));

	local data = resTableManager:GetValue(ResTable.tutorial_role, self.resID,
				{'skill_id', 'skill_id2', 'skill_id3',
				 'skill_passive', 'skill_passive2',
				 'skill_auto', 'skill_auto2', 'skill_auto3'});
	local skillData = {
		{['resid'] = data['skill_id'], ['level'] = 1},
		{['resid'] = data['skill_id2'], ['level'] = 1},
		{['resid'] = data['skill_id3'], ['level'] = 1},
		{['resid'] = data['skill_passive'], ['level'] = 1},
		{['resid'] = data['skill_passive2'], ['level'] = 1},
		{['resid'] = data['skill_auto'], ['level'] = 1},
		{['resid'] = data['skill_auto2'], ['level'] = 1},
		{['resid'] = data['skill_auto3'], ['level'] = 1},
	}
	for _, skill in ipairs(skillData) do
		if nil ~= skill.resid and skill.level ~= 0 then
			local skillType = resTableManager:GetValue(ResTable.skill, tostring(skill.resid), 'skill_type');
			local skillClass = resTableManager:GetValue(ResTable.skill, tostring(skill.resid), 'skill_class');
			local isHalo = resTableManager:GetValue(ResTable.skill, tostring(skill.resid), 'is_halo');
			local target1 = resTableManager:GetValue(ResTable.skill, tostring(skill.resid), 'target');
			local target2 = resTableManager:GetValue(ResTable.skill, tostring(skill.resid), 'target2');

    	--Debug.var_dump({name = "isHalo", id = skill.resid, data = isHalo});

			if (skillType ~= nil) then
				if skillType == 0 then			--主动技能
					table.insert(self.m_skillList, FightActiveSkillClass.new(self, skill.resid, skill.level));

					--分为被动可释放和被动光环效果
				elseif (skillType == 1) and (tonumber(isHalo) == 1) then -- 光环效果
					local buffdata1 = resTableManager:GetValue(ResTable.skill, tostring(skill.resid), 'buff_data1');
					if type(buffdata1) == 'table' then
						__.each(buffdata1, function(buffid)
							table.insert(self.m_haloBuffIDList, {id = buffid[2], target = target1});
						end)
					end


					local buffdata2 = resTableManager:GetValue(ResTable.skill, tostring(skill.resid), 'buff_data2');
					if type(buffdata2) == 'table' then
						__.each(buffdata2, function(buffid)
							table.insert(self.m_haloBuffIDList, {id = buffid[2], target = target2});
						end)
					end
				elseif (skillType == 1) and (skill.level > 0) then		--被动技能
					table.insert(self.m_skillList, FightPassiveSkillClass.new(self, skill.resid, skill.level));
				end
			end
		end
	end


	--加载技能的技能脚本
	self:LoadSkillScript();

	--根据技能的优先级排序
	self:SortSkillByPriority();
end

--更新
function Fighter_Novice_Player:Update(elapse)
   if(tonumber(self.resID) > 100 and tonumber(self.resID) < 200 and CheckDiv(self:GetCurrentHP() / self:GetMaxHP()) < TriggerPlotTime[2]) then
		print("aaa" .. self:GetCurrentHP() .. self:GetMaxHP());
		EventManager:FireEvent(EventType.Time, 100001, TriggerPlotTime[2]);
		TriggerPlotTime[2] = -1;
	end
	--基类最后更新
	Fighter.Update(self, elapse);

	--判断是否进入警戒线
	if	(nil ~= FightManager:GetAlertLineXposition()) and (self:GetPosition().x >= FightManager:GetAlertLineXposition()) then
		FightManager:SetFirstIdleMonsterWakeUpTime(true);
	end
end

--更新保持待机状态的处理函数
--只有玩家进场的时候会存在保持待机状态
function Fighter_Novice_Player:updateStateKeepIdle(elapse)
	self.m_keepIdleLastTime = self.m_keepIdleLastTime + elapse;
	if self.m_keepIdleLastTime >= Configuration.FirstEnterFightStayTime then
		self:SetIdle();
	end
end

--======================================================================
--子类重写父类方法
function Fighter_Novice_Player:SetDie()
	--删除角色头像上的技能图标
	FightUIManager:DestroySkillEffect(self.m_teamIndex);

	Fighter.SetDie(self);
end

--获取基本数据
function Fighter_Novice_Player:GetBaseDataFromTable()
	return resTableManager:GetRowValue(ResTable.tutorial_role, self.resID);
end

--获取普通技能脚本名称和进阶技能脚本名称(子类重写父类方法)
function Fighter_Novice_Player:GetAllSkillScriptName()
	return resTableManager:GetValue(ResTable.tutorial_role, self.resID, 'skill_script');
end

function Fighter_Novice_Player:InitFightData(roleid)
	naviInfo = resTableManager:GetRowValue(ResTable.navi_main, tostring(roleid));
	self.m_headImage = naviInfo['role_path_icon'];
end
