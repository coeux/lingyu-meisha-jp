--=============================================================================
--战斗中的玩家类

Fighter_Player = class(Fighter);

function Fighter_Player:constructor(id, resID)
	--初始化角色基本数据
	self.m_propertyData:InitPlayerBaseData(false);
	
	--角色入场时保持待机状态的持续时间
	self.m_keepIdleLastTime = 0;								--角色入场时保持待机状态的持续时间
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
	self:initSkillData(data.skls);
end

--初始化角色技能
function Fighter_Player:initSkillData(skillData)
	--将普通攻击添加到技能列表中
	table.insert(self.m_skillList, FightNormalSkillClass.new(self));
	
	for _, skill in ipairs(skillData) do
		local skillType = resTableManager:GetValue(ResTable.skill, tostring(skill.resid), 'skill_type');
		if (skillType ~= nil) then
			if skillType == 0 then			--主动技能
				table.insert(self.m_skillList, FightActiveSkillClass.new(self, skill.resid, skill.level));
			elseif (skillType == 1) and (skill.level > 0) then		--被动技能
				table.insert(self.m_skillList, FightPassiveSkillClass.new(self, skill.resid));
			end
		end
	end	
	
	--加载技能的技能脚本
	self:LoadSkillScript();
	
	--根据技能的优先级排序
	self:SortSkillByPriority();
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
	Fighter.SetDie(self);
end

--获取基本数据
function Fighter_Player:GetBaseDataFromTable()
	return resTableManager:GetRowValue(ResTable.actor, tostring(self.resID));			
end

--获取普通技能脚本名称和进阶技能脚本名称(子类重写父类方法)
function Fighter_Player:GetAllSkillScriptName()
	return resTableManager:GetValue(ResTable.actor, self.resID, {'skill_script', 'next_skill'});
end
