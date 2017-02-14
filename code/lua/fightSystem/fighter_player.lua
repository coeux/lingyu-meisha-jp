--fighter_player.lua
--=================================================================
LoadLuaFile("lua/fightSystem/fighter.lua");
--=============================================================================
--战斗中的玩家类

Fighter_Player = class(Fighter);

function Fighter_Player:constructor(id, resID, is_enemy)
	--初始化角色基本数据
	self.m_propertyData:InitPlayerBaseData(false);
	if is_enemy then 
		self.m_isEnemy = true;
	else
		self.m_isEnemy = false;
	end;
	self:LoadRune();
	
	--预加载角色美术资源
	self:PreLoadAvatarResource(false, false);
	
	--角色入场时保持待机状态的持续时间
	self.m_keepIdleLastTime = 0;
end

--初始化角色形象（要在战斗预加载结束之后才能执行）
function Fighter_Player:InitAvatar()
	--执行父类函数
	Fighter.InitAvatar(self);
	
	--初始化角色形象
	self.m_avatarData:InitPlayerAvatar(false);
end

--根据服务器数据初始化战斗数据
function Fighter_Player:InitFightData(data)
	self.m_level = data.lvl.level;						--角色等级
	self.m_propertyData:InitPlayerFightData(data);
  --头像
  self.m_headImage = data.headImage;
	self:initSkillData(data.skls);

	--初始化翅膀id
	local windData = data.wings;
	if (windData ~= nil) and (#windData > 0) then
		self.m_wingID = windData[1].resid;
	end
end

--初始化角色技能
function Fighter_Player:initSkillData(skillData)
	--将普通攻击添加到技能列表中
	table.insert(self.m_skillList, FightNormalSkillClass.new(self));
	
	for _, skill in ipairs(skillData) do
		if skill.level ~= 0 then
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
							table.insert(self.m_haloBuffIDList, {id = buffid[2], target = target1, level = skill.level or 1});
						end)
					end


					local buffdata2 = resTableManager:GetValue(ResTable.skill, tostring(skill.resid), 'buff_data2');
					if type(buffdata2) == 'table' then
						__.each(buffdata2, function(buffid)
							table.insert(self.m_haloBuffIDList, {id = buffid[2], target = target2, level = skill.level or 1});
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
function Fighter_Player:Update(elapse)
	--基类最后更新
	Fighter.Update(self, elapse);

	--判断是否进入警戒线
	if	(nil ~= FightManager:GetAlertLineXposition()) and (self:GetPosition().x >= FightManager:GetAlertLineXposition()) then
		FightManager:SetFirstIdleMonsterWakeUpTime(true);
	end
end

--更新保持待机状态的处理函数
--只有玩家进场的时候会存在保持待机状态
function Fighter_Player:updateStateKeepIdle(elapse)
	self.m_keepIdleLastTime = self.m_keepIdleLastTime + elapse;
	if self.m_keepIdleLastTime >= Configuration.FirstEnterFightStayTime then
		self:SetIdle();
	end
end

--======================================================================
--子类重写父类方法
function Fighter_Player:SetDie()
	--删除角色头像上的技能图标
	FightUIManager:DestroySkillEffect(self.m_teamIndex);
	
	Fighter.SetDie(self);
end

--获取基本数据
function Fighter_Player:GetBaseDataFromTable()
	return resTableManager:GetRowValue(ResTable.actor, tostring(self.resID));			
end

--获取普通技能脚本名称和进阶技能脚本名称(子类重写父类方法)
function Fighter_Player:GetAllSkillScriptName()
	return resTableManager:GetValue(ResTable.actor, self.resID, {'skill_script', 'skill_script2', 'skill_script3', 'next_skill', 'next_skill2', 'next_skill3'});
end
