--fighter.lua
--============================================================================
LoadLuaFile("lua/actor/Actor.lua");
--============================================================================
--战斗者

Fighter = class(Actor)

function Fighter:constructor(id, resID)
	self.m_propertyData      = FighterPropertyData.new(self); -- 角色基本属性类

	-- 其他战斗相关属性
	-- 类别相关
	self.m_actorType         = 0;                             -- 角色类型（主角、伙伴、怪物、boss）
	self.m_isEnemy           = false;                         -- 是否敌方角色

	-- 角色相关
	self.m_level             = 0;                             -- 角色等级

	self.m_isHit             = false;                         -- 是否被攻击
	self.m_hitTime           = 0;                             -- 被击后的持续时间

	-- 站位相关
	self.m_yPosition          = Configuration.YOrderAllPosition[2];-- 角色打斗站位
	self.m_standArea          = 1;                             -- 站立区
	self.m_xAdjust            = 0;                             -- 站位调整x
	self.m_yAdjust            = 0;                             -- 站位调整y
	self.m_attackRange        = 0; -- 角色攻击范围
	self.m_distanceCompensation      = 0; -- 菱形站位时不同站位线的距离补偿

	-- 战斗相关
	self.m_teamIndex         = 0;                             -- 角色的出场顺序
	self.m_enterLine         = 2;                             -- 角色出场线
	self.m_isEnterFight      = false;                         -- 角色是否已经进入战斗
	self.m_isMoveEnd         = false;                         -- 角色是down否已经移动到终点
	self.m_fighterstate      = FighterState.idle;             -- 角色在战斗过程中的状态
	self.m_curAttackLastTime = 0;                             -- 该次攻击的持续时间
	self.m_attackCount       = 0;                             -- 本次战斗中的攻击次数
	self.m_releaseSkillFlag  = false;                         -- 技能释放标志位（当该变量为true时，释放技能）
	self.m_goodsIDList       = {};                            -- 角色死亡时掉落物品的id列表

	-- 技能
	self.m_skillList         = {};                            -- 角色技能列表
	self.m_curSkill          = nil;                           -- 当前释放的技能

	-- 技能展示
	self.m_RunningState      = false;                         -- 无视战斗运行状态，如果为true更新，false则根据战斗运行状态
	self.m_ZOrder            = 0;
	self.m_HaveBringToFront  = false;
	self.m_IsShowSkill       = false;                         -- 是否处于技能展示过程

	-- buff
	self.m_buffItemList      = {};                            -- 角色身上的buff

	-- 翅膀id
	self.m_wingID            = 0;                             -- 翅膀id

	--特殊状态标志位
	self:InitSpecialState();
	self:InitHaloState(); -- 初始化光环状态
	self:InitMarkState(); -- 初始化标记状态
	self.m_thornsProbability       = 0; -- 反伤概率
	self.m_bloodThirstyProbability = 0; -- 吸血百分比
	self.m_moreAnger               = 0; -- 额外怒气值
	self.m_dodgeAddAnger           = 0; -- 每次闪避获得的额外怒气值
	self.m_recoverEffect           = 0; -- 回复效果
	self.m_realDamageRatio          = 0; -- 真实伤害承受比例
	self.m_comboDamageRatio        = 0; -- combo伤害比例

	--个人光环效果
	--
	self.m_haloBuffIDList = {};                                     -- 自带的被动效果，上场触发不可驱散

	self.debuginfo = "";
end

--初始化角色形象（要在战斗预加载结束之后才能执行）
function Fighter:InitAvatar()
	self.m_avatarData = FightAvatarData.new(self);    --角色形象类
end

--预加载角色美术资源
function Fighter:PreLoadAvatarResource(isMonster, isNovice)
	--[[  local contents = nil;
	if isNovice then
		-- ???
		-- contents = resTableManager:GetValue(ResTable.tutorial_role, self.resID, 'path');
	else
		if isMonster then
			contents = resTableManager:GetValue(ResTable.monster, self.resID, 'path');
		else
			contents = resTableManager:GetValue(ResTable.actor, self.resID, 'path');
		end
	end

	asyncLoadManager:PreLoadArmature(GlobalData.AnimationPath .. contents .. '/');
--]]
end

--初始化角色的特殊状态标志位
function Fighter:InitSpecialState()
	self.m_specialStateFlag = {};
	self.m_specialStateFlag[FightSpecialStateType.Freeze]           = false; -- 冰冻
	self.m_specialStateFlag[FightSpecialStateType.Dizziness]        = false; -- 眩晕
	self.m_specialStateFlag[FightSpecialStateType.Invincible]       = false; -- 无敌
	self.m_specialStateFlag[FightSpecialStateType.Thorns]           = false; -- 反伤
	self.m_specialStateFlag[FightSpecialStateType.Immune]           = false; -- 免疫
	self.m_specialStateFlag[FightSpecialStateType.Blind]            = false; -- 目盲
	self.m_specialStateFlag[FightSpecialStateType.Chaos]            = false; -- 混乱
	self.m_specialStateFlag[FightSpecialStateType.Silence]          = false; -- 沉默
	self.m_specialStateFlag[FightSpecialStateType.Deny]             = false; -- 法术否定
	self.m_specialStateFlag[FightSpecialStateType.Bloodthirsty]     = false; -- 嗜血
	self.m_specialStateFlag[FightSpecialStateType.Cleanse]          = false; -- 净化
	self.m_specialStateFlag[FightSpecialStateType.Relieve]          = false; -- 解除
	self.m_specialStateFlag[FightSpecialStateType.DodgeAddAnger]    = false; -- 闪避增加怒气
end

--初始化光环
function Fighter:InitHaloState()
	self.m_specialStateFlag[FightSpecialStateType.NoAnger]           = false; -- 不得怒气(光环)
	self.m_specialStateFlag[FightSpecialStateType.MoreAnger]         = false; -- 获取额外怒气(光环)
	self.m_specialStateFlag[FightSpecialStateType.HaloThorns]        = false; -- 反伤（光环）
	self.m_specialStateFlag[FightSpecialStateType.HaloImmuneDamage]  = false; -- 免伤（光环）
	self.m_specialStateFlag[FightSpecialStateType.HaloDamage]        = false; -- 伤害提升/降低（光环）
	self.m_specialStateFlag[FightSpecialStateType.HaloRecoverEffect] = false; -- 恢复效果提升(光环)
	self.m_specialStateFlag[FightSpecialStateType.HaloComboDamage]   = false; -- combo伤害提升/降低
	--技能属性
	self:InitSkillAddition();
end

--技能属性加成（光环）
function Fighter:InitSkillAddition()
	self.m_specialStateFlag[FightSpecialStateType.SkillProperty0] = false;  --无
	self.m_specialStateFlag[FightSpecialStateType.SkillProperty1] = false;  --风火水土
	self.m_specialStateFlag[FightSpecialStateType.SkillProperty2] = false;
	self.m_specialStateFlag[FightSpecialStateType.SkillProperty3] = false;
	self.m_specialStateFlag[FightSpecialStateType.SkillProperty4] = false;
	self.m_skillAddition =
	{
		property0 = 0;
		property1 = 0;
		property2 = 0;
		property3 = 0;
		property4 = 0;
	}
end

--初始化标记
function Fighter:InitMarkState()
	--技能属性
	self:InitMarkSkillAddition();
end

--技能属性加成（标记）
function Fighter:InitMarkSkillAddition()
	self.m_specialStateFlag[FightSpecialStateType.MarkSkillProperty0] = false;  --无
	self.m_specialStateFlag[FightSpecialStateType.MarkSkillProperty1] = false;  --风火水土
	self.m_specialStateFlag[FightSpecialStateType.MarkSkillProperty2] = false;
	self.m_specialStateFlag[FightSpecialStateType.MarkSkillProperty3] = false;
	self.m_specialStateFlag[FightSpecialStateType.MarkSkillProperty4] = false;
	self.m_markSkillAddition =
	{
		property0 = 0;
		property1 = 0;
		property2 = 0;
		property3 = 0;
		property4 = 0;
	}
end

function Fighter:LoadRune()
	if self.m_isEnemy then
		-- 伤害加成
		self.m_skillAddition.property0 = Rune:GetEValueByRidAid(self.resID, FightSpecialStateType.SkillProperty0);
		self.m_skillAddition.property1 = Rune:GetEValueByRidAid(self.resID, FightSpecialStateType.SkillProperty1);
		self.m_skillAddition.property2 = Rune:GetEValueByRidAid(self.resID, FightSpecialStateType.SkillProperty2);
		self.m_skillAddition.property3 = Rune:GetEValueByRidAid(self.resID, FightSpecialStateType.SkillProperty3);
		self.m_skillAddition.property4 = Rune:GetEValueByRidAid(self.resID, FightSpecialStateType.SkillProperty4);
		-- 抗性加成
		self.m_markSkillAddition.property0 = Rune:GetEValueByRidAid(self.resID, FightSpecialStateType.MarkSkillProperty0);
		self.m_markSkillAddition.property1 = Rune:GetEValueByRidAid(self.resID, FightSpecialStateType.MarkSkillProperty1);
		self.m_markSkillAddition.property2 = Rune:GetEValueByRidAid(self.resID, FightSpecialStateType.MarkSkillProperty2);
		self.m_markSkillAddition.property3 = Rune:GetEValueByRidAid(self.resID, FightSpecialStateType.MarkSkillProperty3);
		self.m_markSkillAddition.property4 = Rune:GetEValueByRidAid(self.resID, FightSpecialStateType.MarkSkillProperty4);
	else
		-- 伤害加成
		self.m_skillAddition.property0 = Rune:GetValueByRidAid(self.resID, FightSpecialStateType.SkillProperty0);
		self.m_skillAddition.property1 = Rune:GetValueByRidAid(self.resID, FightSpecialStateType.SkillProperty1);
		self.m_skillAddition.property2 = Rune:GetValueByRidAid(self.resID, FightSpecialStateType.SkillProperty2);
		self.m_skillAddition.property3 = Rune:GetValueByRidAid(self.resID, FightSpecialStateType.SkillProperty3);
		self.m_skillAddition.property4 = Rune:GetValueByRidAid(self.resID, FightSpecialStateType.SkillProperty4);
		-- 抗性加成
		self.m_markSkillAddition.property0 = Rune:GetValueByRidAid(self.resID, FightSpecialStateType.MarkSkillProperty0);
		self.m_markSkillAddition.property1 = Rune:GetValueByRidAid(self.resID, FightSpecialStateType.MarkSkillProperty1);
		self.m_markSkillAddition.property2 = Rune:GetValueByRidAid(self.resID, FightSpecialStateType.MarkSkillProperty2);
		self.m_markSkillAddition.property3 = Rune:GetValueByRidAid(self.resID, FightSpecialStateType.MarkSkillProperty3);
		self.m_markSkillAddition.property4 = Rune:GetValueByRidAid(self.resID, FightSpecialStateType.MarkSkillProperty4);
	end
end

--更新
function Fighter:Update(elapse)
	if not self.m_isEnterFight then
		return;        --如果没有进入战斗，则直接返回
	end

	if (not FightManager:IsRunning()) and (not self.m_RunningState) then
		return;        --如果游戏不再运行状态，则战斗角色不更新
	end

	if self.m_fighterstate == FighterState.death then
		return;        --如果处于死亡状态，返回
	end

	--基类更新
	Actor.Update(self, elapse);

	--更新角色的状态
	self:updateFighterState(elapse);

	--更新buff
	self:updateBuff(elapse);

	--更新被击状态
	self:updateHitState(elapse);
end

--更新角色状态
function Fighter:updateFighterState(elapse)
	self:updateSkillReleaseFlag();                  --更新技能释放标志位

	if FighterState.idle == self.m_fighterstate then          --当前状态为待机状态
		self:updateStateIdle(elapse);

	elseif FighterState.keepIdle == self.m_fighterstate then      --当前状态为保持待机状态
		self:updateStateKeepIdle(elapse);

	elseif FighterState.moving == self.m_fighterstate then        --当前状态为移动状态
		self:updateStateMoving(elapse);

	elseif FighterState.skillAttack == self.m_fighterstate then    --当前状态为释放技能状态
		self:updateStateSkillAttack(elapse);

	elseif FighterState.pauseAction == self.m_fighterstate then    --当前状态为定身状态
		--定身状态不做任何更新
		--Debug.print("dingshen------------------ " .. self.resID);

	else     --其它状态
		return;
	end
end

function Fighter:castHalo()
	--给列表中的所有人加上buffid对应的光环
	function addBuffToAll(list, buffid, buffLevel)
		__.each(list, function(actor)
			actor:AddBuff(buffid, self, nil, true, buffLevel);
		end)
	end

	if not self.alreadyCastedHalo then
		__.each(self.m_haloBuffIDList, function(buff)
			local buffid = buff.id;
			local target = buff.target;
			if target == 1 then --自己
				self:AddBuff(buffid, self, nil, true, buff.level); --第四个参数是lastforever,光换buff
			elseif target == 2 then --己方所有人
				if not self.m_isEnemy then
					addBuffToAll(FightManager.leftActorList, buffid, buff.level)
				else
					addBuffToAll(FightManager.rightActorList, buffid, buff.level)
				end
			elseif target == 4 then --敌方所有人
				if self.m_isEnemy then
					addBuffToAll(FightManager.leftActorList, buffid, buff.level)
				else
					addBuffToAll(FightManager.rightActorList, buffid, buff.level)
				end
			end
		end)
		self.alreadyCastedHalo = true; -- do not cast any more
	end
end

--更新角色身上的buff
function Fighter:updateBuff(elapse)
	if FightManager.state ~= FightState.fightState then
		return;
	end


	local buffIndex = 1;
	while self.m_buffItemList[buffIndex] ~= nil do
		local buffItem = self.m_buffItemList[buffIndex];
		if buffItem:IsEnd() and not buffItem.m_lastForever then
			--buff已经结束，从bufflist里面将buffItem删除
			table.remove(self.m_buffItemList, buffIndex);
		else
			buffItem:Update(elapse);
			buffIndex = buffIndex + 1;
		end
	end
end

--更新被攻击状态
function Fighter:updateHitState(elapse)
	if self.m_isHit then
		self.m_hitTime = self.m_hitTime + elapse;
		if (self.m_hitTime > Configuration.StayRedTime) then      --超过被击变红的时间
			self:SetColor(Color.White);
			self.m_isHit = false;
			self.m_hitTime = 0;
		end
	end
end

--=============================================================================================
--加载技能的技能脚本
function Fighter:LoadSkillScript()
	for _, skill in ipairs(self.m_skillList) do
		skill:LoadScriptResource();
	end
end

--根据技能的优先级进行排序
function Fighter:SortSkillByPriority()
	table.sort(self.m_skillList, function (skill1, skill2)
		return skill1:GetPriority() > skill2:GetPriority();
	end);
end

--遍历角色技能，寻找技能释放目标。如果找到，则释放技能
function Fighter:CanReleaseSkill(elapse)
	if self.m_curSkill and self.m_curSkill.isCasting then
		return;
	end
	for _, skillItem in ipairs(self.m_skillList) do
		if skillItem:GetReleaseFlag() then
			skillItem:CanReleaseSkill(elapse);
			break;
		end
	end
end

--更新待机状态的处理函数
function Fighter:updateStateIdle(elapse)
	--如果是录像模式，则保持待机状态
	if FightManager:IsRecord() then
		return;
	end

	--判断技能释放条件，如果成立，则释放技能
	self:CanReleaseSkill(elapse);
end

--更新保持待机状态的处理函数
function Fighter:updateStateKeepIdle(elapse)
	-- body
end

--更新移动状态的处理函数
function Fighter:updateStateMoving(elapse)
	--如果是录像模式，则保持移动状态
	if FightManager:IsRecord() then
		self:move(elapse);
		return;
	end

	--判断技能释放条件，如果成立，则释放技能
	self:CanReleaseSkill(elapse);
end

--更新技能攻击状态的处理函数
function Fighter:updateStateSkillAttack(elapse)

	if self.m_curSkill == nil then
		--如果当前技能为空，则直接返回
		return;
	end

	if not FightManager:IsRecord() then
		for _, skillItem in ipairs(self.m_skillList) do
			if skillItem:GetPriority() > self.m_curSkill:GetPriority() then
				--如果技能优先级大于当前技能优先级，则判断技能是否可以释放
				if skillItem:GetReleaseFlag() then
					skillItem:CanReleaseSkill(elapse);
					return;
				end
			else
				--如果技能优先级小于等于当前技能优先级，则直接跳出循环
				break;
			end
		end
	end

	self.m_curSkill:Update(elapse);
end

--=========================================================================================
--更新技能释放标志位
function Fighter:updateSkillReleaseFlag()
	if FightComboQueue:onComboQueue() then
		return;
	end
	for _, skillItem in ipairs(self.m_skillList) do
		skillItem:UpdateReleaseSkillFlag();
	end
end

--获取手动战斗模式下是否可以释放技能
function Fighter:CanReleaseSkillInManualModal()
	if FightManager:IsAuto() or FightManager:IsRecord() or FightManager:IsOver() then
		--自动模式下返回false
		return false;
	end

	if self.m_isEnemy then
		return false;
	end

	if self.m_fighterstate == FighterState.death then
		--如果角色死亡返回false
		return false;
	end

	if self:GetCurrentAnger() < Configuration.MaxAnger then
		--如果怒气不满返回false
		return false;
	end

	if self.m_IsShowSkill then
		--如果处于技能展示过程，返回false
		return false;
	end

	return true;
end

--=========================================================================================
--技能相关
--展示技能
function Fighter:ShowSkill(newSkill)

	if self.m_curSkill and self.m_curSkill.isCasting and FightComboQueue:onComboQueue() then

		Debug.print("[".. self.m_curSkill.m_scriptName .. "] now m_curSkill / [".. newSkill.m_scriptName .. "] newSkill" );
		if newSkill.m_skillClass == SkillClass.counterSkill then
		elseif newSkill.m_skillClass == SkillClass.comboSkill then
		else
			return;
		end
	end
	self.m_curSkill = newSkill;                --设置当前释放的技能
	self.m_IsShowSkill = true;
	self:SetRunningState(false);              --取消强制更新
	EventManager:FireEvent(EventType.ShowSkill, self, newSkill);    --触发展示技能事件

	Actor.PauseAction(self, false);            --暂停动作，防止出现角色跑动bug
end

--展示技能结束后真正执行技能
function Fighter:RunRealSkill()
	self:ResetAnger();                    --重置怒气
	self:SetFighterState(FighterState.skillAttack);    --设置技能状态
	self.m_IsShowSkill = false;                --将技能展示标志设置成false

	--[[
	if not self.m_curSkill or not self.m_curSkill.RunRealSkill then
		Debug.print("no RunRealSkill " .. self.m_curSkill.m_scriptName);
		self.m_curSkill.isCasting = false;

		return;
	end

	--  Debug.assert(self.m_curSkill.RunRealSkill, self.resID .. "释放技能失败？")
	self.m_curSkill:RunRealSkill();
	--]]
	--正式释放技能时，隐藏血条
	HpProgressBarManager:HideProgressBar(self:GetID());
end

--=========================================================================================
--移动相关
function Fighter:move(elapse)
	if self:isArriveTerminal() then
		--移动到终点，位置保持不变，执行待机动作
		self:SetIdle();
	else
		--没有移动到终点，则继续向前移动
		self:moveForward(elapse);
		if self.m_curSkill then
			self.m_curSkill.isCasting = false;
		end
	end
end
--向前移动角色
function Fighter:moveForward(elapse)
	if not elapse then
		return;
	end
	local sign = 1;
	if (self:GetDirection() == DirectionType.faceleft) then
		sign = -1;
	end

	local dis = self.m_propertyData:GetPropertyData(FighterPropertyType.movSpe) * elapse * sign;
	local pos = self:GetPosition();

	--站位调整
	local standAdjust = Configuration.StandAreaAdjust[self.faceDir][self.m_standArea];
	local adjust = pos.y == self.m_yPosition and 0 or (pos.y < self.m_yPosition and 1 or -1)
	local x_adjust = (self.m_xAdjust ~= standAdjust[1]) and (standAdjust[1] > 0 and 1 or -1) or 0;
	local y_adjust = (self.m_yAdjust ~= standAdjust[2]) and (standAdjust[2] > 0 and 1 or -1) or 0;
	self.m_xAdjust = self.m_xAdjust + x_adjust;
	self.m_yAdjust = self.m_yAdjust + y_adjust;

	self:SetPosition(Vector3(pos.x + dis + x_adjust, pos.y + adjust + y_adjust, 0));

	--判断角色移动之后是否越位
	local flag, xpos = FightManager:GetForwardPosition(self);
	if not flag then
		self:SetPosition(Vector3(xpos, pos.y, 0));
	end

	self:SetMove();
end

--判断角色是否移动到终点
function Fighter:isArriveTerminal()
	if self.m_isMoveEnd then
		return true;
	end

	local minDis = self:GetMinAttackRange() + self:GetWidth() / 2;

	if (self:GetDirection() == DirectionType.faceright) then      --朝右
		if (self:GetPosition().x + minDis >= FightManager:GetBornPosition(self:GetDirection() ) ) then
			self.m_isMoveEnd = true;
			return true;
		else
			return false;
		end
	else
		if (self:GetPosition().x - minDis <= FightManager:GetBornPosition(self:GetDirection() ) ) then
			self.m_isMoveEnd = true;
			return true;
		else
			return false;
		end
	end
end

--=========================================================================================
--特殊状态相关
--设置角色的特殊状态
function Fighter:SetSpecialState(stateType, state)
	self.m_specialStateFlag[stateType] = state;
end

--获取角色的特殊状态
function Fighter:isSpecialState(stateType)
	return self.m_specialStateFlag[stateType];
end

--反伤比
function Fighter:ModifyThornsProbability(value)
	self.m_thornsProbability = self.m_thornsProbability + value;
	self.m_thornsProbability = self.m_thornsProbability >= 0 and self.m_thornsProbability or 0;
end

--吸血比例
function Fighter:ModifyThirstyProbability(value)
	self.m_bloodThirstyProbability = self.m_bloodThirstyProbability + value;
	self.m_bloodThirstyProbability = self.m_bloodThirstyProbability >= 0 and self.m_bloodThirstyProbability or 0;
end

--额外怒气值
function Fighter:ModifyMoreAnger(value)
	self.m_moreAnger = self.m_moreAnger + value;
	self.m_moreAnger = self.m_moreAnger >= 0 and self.m_moreAnger or 0;
end

--闪避后额外获得的怒气值
function Fighter:ModifyDodgeAddDanger(value)
	self.m_dodgeAddAnger = value
	self.m_dodgeAddAnger = self.m_dodgeAddAnger >= 0 and self.m_dodgeAddAnger or 0;
end

--恢复效果
function Fighter:ModifyRecoverEffect(value)
	self.m_recoverEffect = self.m_recoverEffect + value
	if self.m_recoverEffect < -1 then
		self.m_recoverEffect = -1;
	end
end

--获取回复效果加成
function Fighter:GetRecoverEffect()
	return self.m_recoverEffect;
end

--真实伤害承受百分比
function Fighter:ModifyRealDamageRatio(value)
	self.m_realDamageRatio = self.m_realDamageRatio + value;
end

--combo伤害承受百分比
function Fighter:ModifyComboDamageRatio(value)
	self.m_comboDamageRatio = self.m_comboDamageRatio + value;
end

--技能属性加成(光环)
function Fighter:ModifySkillPropertyValue(skillPropertyType, value)
	if skillPropertyType == FightSpecialStateType.SkillProperty0 then
		self.m_skillAddition.property0 = self.m_skillAddition.property0  + value;
	elseif skillPropertyType == FightSpecialStateType.SkillProperty1 then
		self.m_skillAddition.property1 = self.m_skillAddition.property1  + value;
	elseif skillPropertyType == FightSpecialStateType.SkillProperty2 then
		self.m_skillAddition.property2 = self.m_skillAddition.property2  + value;
	elseif skillPropertyType == FightSpecialStateType.SkillProperty3 then
		self.m_skillAddition.property3 = self.m_skillAddition.property3  + value;
	elseif skillPropertyType == FightSpecialStateType.SkillProperty4 then
		self.m_skillAddition.property4 = self.m_skillAddition.property4  + value;
	end
end
--获得技能属性加成
function Fighter:GetSkillPropertyValue(skillPropertyType)
	if skillPropertyType == FightSpecialStateType.SkillProperty0 then
		return self.m_skillAddition.property0;
	elseif skillPropertyType == FightSpecialStateType.SkillProperty1 then
		return self.m_skillAddition.property1;
	elseif skillPropertyType == FightSpecialStateType.SkillProperty2 then
		return self.m_skillAddition.property2;
	elseif skillPropertyType == FightSpecialStateType.SkillProperty3 then
		return self.m_skillAddition.property3;
	elseif skillPropertyType == FightSpecialStateType.SkillProperty4 then
		return self.m_skillAddition.property4;
	else
		return 0;
	end
end

--技能属性加成(标记)
function Fighter:ModifyMarkSkillPropertyValue(skillPropertyType, value)
	if skillPropertyType == FightSpecialStateType.MarkSkillProperty0 then
		self.m_markSkillAddition.property0 = self.m_markSkillAddition.property0  + value;
	elseif skillPropertyType == FightSpecialStateType.MarkSkillProperty1 then
		self.m_markSkillAddition.property1 = self.m_markSkillAddition.property1  + value;
	elseif skillPropertyType == FightSpecialStateType.MarkSkillProperty2 then
		self.m_markSkillAddition.property2 = self.m_markSkillAddition.property2  + value;
	elseif skillPropertyType == FightSpecialStateType.MarkSkillProperty3 then
		self.m_markSkillAddition.property3 = self.m_markSkillAddition.property3  + value;
	elseif skillPropertyType == FightSpecialStateType.MarkSkillProperty4 then
		self.m_markSkillAddition.property4 = self.m_markSkillAddition.property4  + value;
	end
end

--获得技能属性加成or减益
function Fighter:GetMarkSkillPropertyValue(skillPropertyType)
	if skillPropertyType == FightSpecialStateType.SkillProperty0 then
		return self.m_markSkillAddition.property0;
	elseif skillPropertyType == FightSpecialStateType.SkillProperty1 then
		return self.m_markSkillAddition.property1;
	elseif skillPropertyType == FightSpecialStateType.SkillProperty2 then
		return self.m_markSkillAddition.property2;
	elseif skillPropertyType == FightSpecialStateType.SkillProperty3 then
		return self.m_markSkillAddition.property3;
	elseif skillPropertyType == FightSpecialStateType.SkillProperty4 then
		return self.m_markSkillAddition.property4;
	else
		return 0;
	end
end

--开始定身状态
function Fighter:BeginPauseActionState()
	--设置定身状态
	---[[

	self:SetFighterState(FighterState.pauseAction);

	--暂停动作
	self:SetAnimation(AnimationType.f_idle);
	Actor.PauseAction(self, false);

	--TODO这里是否应该直接从updateitem里面删除自己
	--删除当前技能脚本

	--[[
	if self.m_curSkill ~= nil then
		self.m_curSkill:EndSkill();
		self.m_curSkill = nil;
	end

	FightShowSkillManager:DeleteActorWaitForCastSkill(self);
	--]]


	--]]
end

--结束定身状态
function Fighter:EndPauseActionState()
	--设置成待机状态
	if self.m_curSkill and self.m_curSkill.isCasting == true then
		self:SetFighterState(FighterState.skillAttack);
	else
		self:SetIdle();
	end
	--恢复动作
	Actor.ContinueAction(self);
end

--是否处于无敌状态
function Fighter:IsInvincible()
	return self.m_specialStateFlag[FightSpecialStateType.Invincible];
end
--=========================================================================================
--Set函数
--设置战斗结束时候的状态
function Fighter:SetStateAfterBattle()
	if self.m_fighterstate == FighterState.moving then
		self:SetIdle();
	end

	self:SetRunningState(false);
end

--设置成待机
function Fighter:SetIdle()
	self:SetFighterState(FighterState.idle);      --设置待机状态
	self:SetAnimation(AnimationType.f_idle);      --设置待机动作
end

--设置保持待机状态
function Fighter:SetKeepIdle()
	self:SetFighterState(FighterState.keepIdle);    --设置保持待机状态
	self:SetAnimation(AnimationType.f_idle);      --设置待机动作
end

--设置成移动
function Fighter:SetMove()
	self:SetFighterState(FighterState.moving);    --设置移动状态
	self:SetAnimation(AnimationType.f_run);              --设置跑步动作
end

--设置成技能
function Fighter:SetSkill(newSkill)
	--设置角色当前状态为技能状态
	self:SetFighterState(FighterState.skillAttack);

	--设置当前释放的技能
	if newSkill ~= nil then
		self.m_curSkill = newSkill;
	end
end

--设置成死亡
function Fighter:SetDie()
	if self.m_fighterstate == FighterState.death then
		return;
	end

        Debug.print("DieID=" .. self.id);

	if self.debug then
		self.debug.Opacity = 0;
		--self.debug = nil
	end
	local soundName = resTableManager:GetValue(ResTable.actor,tostring(self:GetResID()),'death_voice')
	if soundName ~= nil then
		SoundManager:PlayVoice( tostring(soundName))
	end
	--删除角色身上的buff
	self:RemoveAllBuff();
	--接触手动标记
	FightManager:DeleteTag(self);

        --FightCard状态更新、清除卡牌
        FightCardPanel:SetPlayerDie(self);

	--如果有当前释放的技能 把该技能结束
	if self.m_curSkill then
		local attackList = FightAttackManager.attackList;
		for _, attackClass in pairs(attackList) do
			if attackClass.m_attacker == self then
				local attackClass = FightAttackManager:GetAttackClass(attackClass.m_id)
				attackClass:Destroy();
				attackClass.m_attackerSkill:EndSkill();
				EventManager:FireEvent(EventType.ResumeFight, attackClass:GetAttacker());
			end
		end
	end

	--血条隐藏
	HpProgressBarManager:HideProgressBar(self:GetID());

	--删除当前正在释放技能的技能脚本
	--[[
	if self.m_curSkill then
		self.m_curSkill:DestroyEffectScript();
	end
	--]]
	--增加怒气
	self:AddKillerAnger();
	--触发角色死亡的事件
	EventManager:FireEvent(EventType.Die, self);
	--更改状态
	self:SetFighterState(FighterState.death);
	--播放死亡动画
	self:SetAnimation('die');

	
end

function Fighter:isAlive()
	return self.m_fighterstate ~= FighterState.death;
end

--获取当前技能
function Fighter:GetCurSkill()
	return self.m_curSkill;
end

--清除当前技能
function Fighter:ClearSkill()
	--当释放技能是攻击或者辅助结束时添加光圈
	if not shiningoff and self.m_curSkill and self.m_curSkill.m_resid then
		local skill_data = resTableManager:GetValue(ResTable.skill, tostring(self.m_curSkill.m_resid), {'skill_class', 'count'});
     	local skill_class_type = FightSkillCardManager:GetSkillClassType(skill_data['skill_class'], skill_data['count']);
		if skill_class_type == 0 or skill_class_type == 5 then
			FightSkillCardManager:specialAddShing();
		end
	end
	self.m_curSkill = nil;
	--技能结束后恢复显示血条
	HpProgressBarManager:ShowProgressBar(self:GetID());
	-- --提示面板
	-- if FightManager.barrierId == 1003 and FightImageGuidePanel.isShowNextPic and ActorManager.user_data.userguide.isnew == 8 then
	-- 	--弹出提示面板
	-- 	FightManager:Pause();
 --        FightImageGuidePanel:onShow('round_3_1', '其他技能', LANG_fight_guide_round_3_1);
 --        FightImageGuidePanel.isShowNextPic = false;
	-- end
end

--增加攻击次数
function Fighter:AddAttackCount()
	self.m_attackCount = self.m_attackCount + 1;
end

--设置是否入场
function Fighter:SetEnterFight()
	self.m_isEnterFight = true;
end

--设置出场线
function Fighter:SetEnterLine(enterLine)
	self.m_enterLine = Configuration.BattleEnterLine[math.mod(enterLine, #Configuration.BattleEnterLine) + 1];
end

--设置绝对出场线
function Fighter:SetAbsoluteEnterLine(enterLine)
	self.m_enterLine = enterLine;
end

--设置状态
function Fighter:SetFighterState(state)
	if self.m_fighterstate == FighterState.death then
		return false;
	end
	if (self.m_fighterstate == state) then
		return false;
	else
		self.m_fighterstate = state;
		return true;
	end
end


--设置最大血量
function Fighter:SetMaxHp(maxHP)
	self.m_propertyData:SetMaxHp(maxHP);
end

--调整血量
function Fighter:AdjustHP(hpValue)
	self.m_propertyData:AdjustHP(hpValue);
end

--扣除血量
function Fighter:DeductHp(value, attacker)
	--判断是否存在无敌状态
	if self.m_specialStateFlag[FightSpecialStateType.Invincible] then
		return;
	end

        self.lastHp = self:GetCurrentHP();
        --print("self.lastHp = " .. self.lastHp);
	if self.m_propertyData:DeductHp(value) then
		--角色死亡
		Debug.print("[Set Die]" .. self.resID)
		self:SetDie();
		if attacker then
			attacker:castTriggerSkill(SkillCause.KillUnit, self);
		end
	end
end

--获取基本数据
function Fighter:GetBaseDataFromTable()
	return nil;
end

--获取属性
function Fighter:GetPropertyData(propertyType)
	return self.m_propertyData:GetPropertyData(propertyType);
end

--获取当前属性
function Fighter:GetCurrentPropertyData()
	return self.m_propertyData:GetCurrentPropertyData();
end

--改变属性
function Fighter:ChangePropertyData(propertyType, value)
	self.m_propertyData:ChangePropertyData(propertyType, value);
end

--设置体型放大倍数
function Fighter:SetShapeScale(scale)
	self.m_propertyData:SetShapeScale(scale);
end

--设置角色类型
function Fighter:SetActorType(actorType)
	self.m_actorType = actorType;
end

--设置站位相关信息
function Fighter:SetStation(index, count)
	self.m_teamIndex = index;
	self.m_standArea = math.floor(index / #Configuration.BattleYPositionLine) % Configuration.StandAreaCount + 1;
	local max = #Configuration.YOrderAllPosition;
	self.m_yPosition = Configuration.YOrderAllPosition[math.mod(count - 1, max) + 1];
	if Configuration.OffsetAngle == 0 then
		self.m_distanceCompensation = 0;
	else
		self.m_distanceCompensation = math.floor(FightManager.interval[self.m_yPosition] / math.tan(math.rad(Configuration.OffsetAngle)));
           CheckDiv(self.m_distanceCompensation);
	end
end

--获取站位补偿
function Fighter:GetDistCompensation()
	return self.m_distanceCompensation;
end

--角色攻击范围
function Fighter:SetAttackRange(range)
	self.m_attackRange = range;
end

--设置被击状态
function Fighter:SetHitState()
	self.m_isHit = true;
	self:SetColor(Configuration.HitColor);
end

--设置是否敌方角色
function Fighter:SetIsEnemy(flag)
	self.m_isEnemy = flag;
end

--设置是否变成墓碑
function Fighter:SetTombstone(flag)
	self.m_avatarData:SetTombstone(flag);
end

--设置position
function Fighter:SetPosition(pos)
	self:GetCppObject().Translate = pos;
        self:GetCppObject().ZOrder = Convert2ZOrder(pos.y);
end

--重置怒气
function Fighter:ResetAnger()
	self.m_propertyData:SetAnger(0);
end

--设置图层
function Fighter:SetZOrder(zOrder)
	if (not self.m_isEnemy) then
		--本方
		self:GetCppObject().ZOrder = zOrder;
	else
		--敌方
		self:GetCppObject().ZOrder = zOrder - 1;
	end
end

--设置是否处于技能展示过程中
function Fighter:SetShowSkillFlag(flag)
	self.m_IsShowSkill = flag;
end

--设置角色running状态
function Fighter:SetRunningState(flag)
	self.m_RunningState = flag;

	if flag and (self.m_fighterstate ~= FighterState.pauseAction) then
		Actor.ContinueAction(self);
	end
end

--获取强制更新状态
function Fighter:GetRunningState()
	return self.m_RunningState;
end

--获取翅膀id
function Fighter:GetWingID()
	return self.m_wingID;
end
--=========================================================================================
--Get函数
--是否敌方角色
function Fighter:IsEnemy()
	return self.m_isEnemy;
end

--获取出场顺序
function Fighter:GetTeamIndex()
	return self.m_teamIndex;
end

--获取角色打斗站位
function Fighter:GetYPosition()
	return self.m_yPosition;
end

--获取角色攻击范围
function Fighter:GetAttackRange()
	return self.m_attackRange;
end

--获取角色站位区
function Fighter:GetStandArea()
	return self.m_standArea;
end

--获取角色站位调整值
function Fighter:GetStandAdjust()
	local adj = {x = self.m_xAdjust, y = self.m_yAdjust};
	return adj;
end

--获取ZOrder
function Fighter:GetZOrder()
	return self:GetCppObject().ZOrder;
end

--获取缩放比例
function Fighter:GetScale()
	return self.m_avatarData:GetScale();
end

--获取角色当前状态
function Fighter:GetFighterState()
	return self.m_fighterstate;
end

--获取角色类型
function Fighter:GetActorType()
	return self.m_actorType;
end

--获取boss名称
function Fighter:GetActorName()
	return self.m_avatarData:GetActorName();
end

--获取技能 和 普通攻击中距离最小的,现在技能攻击距离确定大于普通攻击距离
function Fighter:GetMinAttackRange()
	return self:GetNormalAttackRange();
end

--获取普通攻击距离
function Fighter:GetNormalAttackRange()
	return self.m_skillList[#self.m_skillList]:GetTriggerRange();
end

--获取属性相关
--是否近战角色
function Fighter:IsMeleeFighter()
	if self:GetJob() == JobType.knight or self:GetJob() == JobType.warrior then
		return true;
	else
		return false;
	end
end

--获取角色星级
function Fighter:GetQuality()
	return self.m_propertyData:GetQuality();
end

--获得职业
function Fighter:GetJob()
	return self.m_propertyData:GetJob();
end

--获取角色的出场线
function Fighter:GetEnterLine()
	return self.m_enterLine;
end

--获取形象名称
function Fighter:GetActorForm()
	return self.m_avatarData:GetActorForm();
end

--根据技能类型获取角色身上的技能
function Fighter:GetSkill(skillType)
	for _, skill in ipairs(self.m_skillList) do
		if skill:GetSkillType() == skillType then
			return skill;
		end
	end

	return nil;
end

--获取攻击次数
function Fighter:GetAttackCount()
	return self.m_attackCount;
end

--获取角色宽度
function Fighter:GetWidth()
	return self.m_propertyData:GetWidth();
end

--获取高度
function Fighter:GetHeight()
	return self.m_propertyData:GetHeight();
end

--获取最大血量
function Fighter:GetMaxHP()
	return self.m_propertyData:GetMaxHP();
end

--获取当前血量
function Fighter:GetCurrentHP()
	return self.m_propertyData:GetCurrentHP();
end

--获取普通技能脚本名称和进阶技能脚本名称(子类重写父类方法)
function Fighter:GetAllSkillScriptName()

end

--获取普通攻击
function Fighter:GetNormalAttack()
	return self.m_propertyData:GetNormalAttack();
end

--获取当前怒气值
function Fighter:GetCurrentAnger()
	return self.m_propertyData:GetCurrentAnger();
end

--设置怒气
function Fighter:SetAnger(anger)
	self.m_propertyData:SetAnger(anger);
end

--对方被杀时给自己增加怒气
function Fighter:AddKillerAnger()
	--同样旷世大战中死亡不给怒气因为已经调整好了无法更改
	if FightManager.mFightType == FightType.noviceBattle then
		return;
	end

	--增加怒气
	local value = self.m_propertyData:GetKillAnger();
	if value then
		if self:IsEnemy() then
			FightManager:AddTotalAnger(value);
		else
			FightManager:AddTotalEnemyAnger(value);
		end
	end

end

function Fighter:AddAnger(value)
	if not self:IsEnemy() then
		FightManager:AddTotalAnger(value);
	else
		FightManager:AddTotalEnemyAnger(value);
	end
end

--攻击增加怒气
function Fighter:AddAtkAnger(targeter, value)
	if self.m_fighterstate == FighterState.death then
		return;
	end
	local incAngerRate = 0;
	if not self:isSpecialState(FightSpecialStateType.NoAnger) then  --当前没有无法获得怒气的debuff
		incAngerRate = self.m_propertyData:GetAttackIncAnger();
	end

	local totalAnger = targeter.m_propertyData:GetTotalAnger();

	--过量伤害不得怒气
        local lastHp = targeter.lastHp;
        if not lastHp then
            lastHp = targeter:GetMaxHP()
        end

        if value > lastHp then
            --print("damage value too large: " .. value .. ", down to :" .. lastHp);
            value = lastHp;
        end

	local angerValue = CheckDiv(value / targeter:GetMaxHP()) * incAngerRate * totalAnger;

	self:AddAnger(angerValue);
end

--受击增加怒气
function Fighter:AddHitAnger(attacker, value)
	if self.m_fighterstate == FighterState.death then
		return;
	end
	--被击增加怒气
	self.m_propertyData:SetAnger(self.m_propertyData:GetCurrentAnger() + self.m_propertyData:GetBeHitIncAnger());

	--计算应该增加的怒气值，考虑“无法获得怒气”debuff状态
	local incAngerRate = 1;
	if not self:isSpecialState(FightSpecialStateType.NoAnger) then  --当前没有无法获得怒气的debuff
		incAngerRate = self.m_propertyData:GetBeHitIncAnger();
	end

	local totalAnger = self.m_propertyData:GetTotalAnger();

	local angerValue = CheckDiv(value / self:GetMaxHP()) * incAngerRate * totalAnger;

	self:AddAnger(angerValue);
end

--获取是否变成墓碑
function Fighter:IsTombstone()
	return self.m_avatarData:IsTombstone();
end

--添加挂点特效
function Fighter:AddAvatarEffect(fileName, avatarName, zorder, avatarPosOffset, avatarPos)
	AvatarManager:LoadFile(GlobalData.EffectPath .. fileName);
	local armature = sceneManager:CreateSceneNode('Armature');
	armature:LoadArmature(avatarName);
	armature:SetAnimation('play');
	armature.ZOrder = zorder;
	armature.Translate = avatarPosOffset;
	self:AttachEffect( avatarPos, armature );
end

--======================================================================================
--技能展示
--将角色提到遮罩前层显示
function Fighter:BringToFront()
            -- 取消此功能
            --[[
	if (not self.m_HaveBringToFront) then
		self.m_ZOrder = self:GetZOrder();
		self.m_HaveBringToFront = true;
		self:GetCppObject().ZOrder = self.m_ZOrder + FightZOrderList.shader + 200;
		FightManager:SortZOrder();
	end
        ]]
end

--还原角色原来的图层
function Fighter:RecoverZOrder()
    -- 取消此功能
    --[[
	if self.m_HaveBringToFront then
		self.m_HaveBringToFront = false;
		self:GetCppObject().ZOrder = self.m_ZOrder;
		FightManager:SortZOrder();
	end
    ]]
end

--设置技能展示动作
function Fighter:SetShowSkillAction()
	--设置待机动作
	self:SetIdle();
	--添加展示特效
	self:AddAvatarEffect('shifangjineng_output/', 'shifangjineng_1', 500, Vector3(0,0,0), AvatarPos.body);
end

--暂停动作
function Fighter:PauseAction(flag)
	if self.m_fighterstate == FighterState.pauseAction then
		return;
	end

	if flag == nil then
		flag = false;
	end

	if (self.m_curSkill ~= nil) then
		self.m_curSkill:PauseScript();
	end

	if not self.m_RunningState then
		--如果没有处于强制更新状态，则暂停动作
		--如果处于强制更新状态，则不暂停动作，
		--防止多个角色放技能时，出现角色动作暂停但是仍然向前移动寻找目标的bug
		Actor.PauseAction(self, flag);
	end
end

--恢复动作
function Fighter:ContinueAction()
	if self.m_fighterstate == FighterState.pauseAction then
		return;
	end

	if (self.m_curSkill ~= nil) then
		self.m_curSkill:ContinueScript();
	end

	Actor.ContinueAction(self);
end

--=========================================================================================
--对敌方！！！！
--随机攻击状态（暴击、闪避和命中）
function Fighter:RandomAttackState(attacker, attackerSkill)

	--guidechange
	if FightManager.mFightType == FightType.normal then
		if FightManager.barrierId == 1001 or FightManager.barrierId == 1002 or FightManager.barrierId == 1003 or FightManager.barrierId == 1004 then
			return AttackState.normal;
		end
	end

	if attackerSkill:GetSkillType() == SkillType.normalAttack then
		local accPro = CaculateAccuracyProbability(attacker, self, attackerSkill);
		if math.random(1, 100) > accPro then
			return AttackState.miss;
		end
	else
		local accPro = CaculateSkillAccuracyProbability(attacker, self, attackerSkill);
		if math.random(1, 100) > accPro then
			return AttackState.miss;
		end
	end

	local criPro = CaculateCriticalProbability(attacker, self);
	if FightManager:GetFightType() == FightType.noviceBattle then
		return AttackState.critical
	end
	if math.random(1, 100) > criPro then
		return AttackState.normal;
	end
	return AttackState.critical;
end

--计算受到的实际伤害
function Fighter:GetActualDamage(attacker, attackerSkill)
	if attackerSkill:GetSkillAttack() == 0 then
		return AttackState.miss, 0;
	end

	local attackState = self:RandomAttackState(attacker, attackerSkill);    --攻击状态（暴击、闪避和命中）

	if (attackState == AttackState.miss) then
		return attackState, 0;                  --如果是miss状态，返回攻击状态miss和实际伤害0
	elseif attacker.m_curSkill then
		attacker.m_curSkill.isHit = true;
	end


	local realDamage = 0;
	if attackerSkill:GetSkillType() == SkillType.normalAttack then
		if attacker:isSpecialState(FightSpecialStateType.Blind) then -- 目盲
			return AttackState.miss, 0;
		end
		realDamage = CaculateNormalAttackDamage(attacker, self, attackerSkill);
	elseif attackerSkill:GetSkillType() == SkillType.activeSkill then
		realDamage = CaculateSkillAttackDamage(attacker, self, attackerSkill);
	elseif attackerSkill:GetSkillType() == SkillType.passiveSkill and attackerSkill:GetSkillClass() == SkillClass.pursuitSkill then
		realDamage = CaculateExtraAttackDamage(attacker, self, attackerSkill);
	end

	if attackState == AttackState.critical then
		realDamage = realDamage * Configuration.StormsHitMultiple;    --计算暴击增益
	end

	--光环伤害提升效果
	if attacker.m_specialStateFlag[FightSpecialStateType.HaloDamage] then
		realDamage = realDamage * (1 + attacker.m_realDamageRatio);
	end
	if attackerSkill:GetSkillType() ~= SkillType.normalAttack and attacker.m_specialStateFlag[FightSpecialStateType.HaloComboDamage] then
		if attackerSkill:GetSkillClass() == SkillClass.startSkill or
			attackerSkill:GetSkillClass() == SkillClass.counterSkill or
			attackerSkill:GetSkillClass() == SkillClass.comboSkill or
			attackerSkill:GetSkillClass() == SkillClass.pursuitSkill then
			realDamage = attacker.m_comboDamageRatio ~= 0 and realDamage * (1 + attacker.m_comboDamageRatio) or realDamage;
		end
	end
	-- if FightManager.mFightType == FightType.noviceBattle then
	-- 	return attackState, realDamage > 0 and realDamage or 3
	-- end
	return attackState, realDamage > 0 and realDamage or math.random(1, 50);
end

--添加受到的伤害
function Fighter:AddDamage(attackerID, attackerSkill, attackClassID)
	local attacker = ActorManager:GetActor(attackerID);
	if (self:GetFighterState() == FighterState.death) then
		--如果该角色已经死亡
		return;
	end

	if (attacker == nil) or (attacker:GetFighterState() == FighterState.death) then
		--如果攻击者不存在或者攻击者已经死亡
		return;
	end


	if attackerSkill.m_skillType ~= SkillType.normalAttack then
		attacker:castTriggerSkill(SkillCause.SkillDamage, self);
	else
		attacker:castTriggerSkill(SkillCause.AttackDamamge, self);
	end

	self:castTriggerSkill(SkillCause.HPDamage, attacker);

	-- 施法疲劳器参数获取
	local damageCoefficient, canAddBuff, phase;
	if attackerSkill.m_skillType == SkillType.activeSkill and not attacker:IsEnemy() then
		damageCoefficient, canAddBuff, phase = FightManager.skillCastCheck.getSkillCoefficient(attackerID, attackClassID);
		FightCardPanel:skillCastCheck(attacker, phase);
	else
		damageCoefficient, canAddBuff = 1, true;
	end

	--计算攻击状态（暴击、命中、闪避）和实际伤害数值
	local state, realDamage = self:GetActualDamage(attacker, attackerSkill);

	local args = {attackerID = attackerID, attackState = state, value = realDamage*damageCoefficient, skillType = attackerSkill:GetSkillType()};
	-- check and add targeter damage
	self:checkStateXorAddDamage(attacker, attackerSkill, args);
	-- check and add attacker hp
	self:checkStateXorAndRecoverHp(attacker, attackerSkill, args);
	-- check and add attacker damage
	self:checkStateXorAddThornsDamage(attacker, attackerSkill, args);
	-- check and add buff
	if canAddBuff then
		self:checkStateXorAddBuff(attacker, attackerSkill);
	end

	--每次攻击均影响场景特效
	FightEffectManager:UpdateEnvEffect(attacker);
end

--检测当前状态xor回复吸收的血量
--args = {attackerID = ?; attackState = ?; value = ?; skillType = ?};
function Fighter:checkStateXorAndRecoverHp(attacker, attackerSkill, args)
	if self:GetFighterState() == FighterState.death then
		return;
	end
	-- 普攻吸血
	if args.attackState ~= AttackState.miss and args.skillType == SkillType.normalAttack then
		if attacker:isSpecialState(FightSpecialStateType.Bloodthirsty) then
			attacker:RecoverHP(math.floor(args.value * attacker.m_bloodThirstyProbability));
		end
	end
end

--检测当前状态xor添加受到伤害
--args = {attackerID = ?; attackState = ?; value = ?; skillType = ?};
function Fighter:checkStateXorAddDamage(attacker, attackerSkill, args)
	if self:GetFighterState() == FighterState.death then
		return;
	end
	if args.attackState ~= AttackState.miss then
		attackerSkill:PlayHitSound();     -- 播放被击音效
		self:AddHitEffect(attackerSkill); -- 攻击没有被闪避,添加被击特效
		if attackerSkill.m_comboResult == FighterComboState.Fall then
			self:SetAnimation(AnimationType.down);
		elseif attackerSkill.m_comboResult == FighterComboState.Repel then
			self:SetAnimation(AnimationType.repel);
		elseif attackerSkill.m_comboResult == FighterComboState.Vertigo then
			local id = EffectManager:allocEffectID();
			local effectData = EffectManager:createEffectData("e503_noloop");
			local effect = BuffAvatarPosEffect.new(id);
			effect:SetEffectData(effectData, false);
			effect:Initialize(self:GetID(), AvatarPos.head, Vector2(0, 0), 1.2, 100, "e503_noloop");

			self:SetAnimation(AnimationType.hit);
		elseif attackerSkill.m_comboResult == FighterComboState.Injured then
			self:SetAnimation(AnimationType.hit);
		end

		--增加combo数量
		
		local anger_table;
		if attacker:IsEnemy() then
			anger_table = ComboPro:getAttributebyAttibute_e(5);
		else
			anger_table = ComboPro:getAttributebyAttibute(5);
		end
		local add_anger_fun = function(combo_, add_num_)
			local sum = 0;
			for k, v in pairs(anger_table) do
				if tonumber(combo_) < tonumber(k) and tonumber(combo_)+tonumber(add_num_) >= tonumber(k) then
					sum = sum + v;
				end
			end
			return sum;
		end

		if attackerSkill.m_skillType == SkillType.activeSkill and attackerSkill.m_skillClass == SkillClass.startSkill then
			local num = resTableManager:GetValue(ResTable.skill, tostring(attackerSkill.m_resid), 'combo_num');
			FightComboQueue:AddComboNum(num, add_anger_fun);
		elseif attackerSkill.m_skillType == SkillType.activeSkill and attackerSkill.m_skillClass == SkillClass.counterSkill then
			local num = resTableManager:GetValue(ResTable.skill, tostring(attackerSkill.m_resid), 'combo_num');
			FightComboQueue:AddComboNum(num, add_anger_fun);
		elseif attackerSkill.m_skillType == SkillType.activeSkill and attackerSkill.m_skillClass == SkillClass.comboSkill then
			local num = resTableManager:GetValue(ResTable.skill, tostring(attackerSkill.m_resid), 'combo_num');
			FightComboQueue:AddComboNum(num, add_anger_fun);
		elseif attackerSkill.m_skillType == SkillType.passiveSkill and attackerSkill.m_skillClass == SkillClass.pursuitSkill then
			local num = resTableManager:GetValue(ResTable.skill, tostring(attackerSkill.m_resid), 'combo_num');
			FightComboQueue:AddComboNum(num, add_anger_fun);
		end
		local is_combo_skill = (attackerSkill.m_skillClass == SkillClass.startSkill) or (attackerSkill.m_skillClass == SkillClass.counterSkill) or (attackerSkill.m_skillClass == SkillClass.pursuitSkill) or (attackerSkill.m_skillClass == SkillClass.counterSkill);
		if is_combo_skill then
			if attacker:IsEnemy() then
				args.value = args.value * (1-ComboPro:getAttributebyAttibute(1)/100) * (1+ComboPro:getAttributebyAttibute_e(3)/100);
			elseif not attacker:IsEnemy() then
				args.value = args.value * (1+ComboPro:getAttributebyAttibute(3)/100) * (1-ComboPro:getAttributebyAttibute_e(1)/100);
			end
		end


		self:DeductHp(args.value,attacker);
		--[[
		if not attacker:IsEnemy() then
			self:DeductHp(1000000,attacker);
		end
		--]]
	elseif args.attackState == AttackState.miss and self:isSpecialState(FightSpecialStateType.DodgeAddAnger) then
		if (self.m_actorType == ActorType.hero) or (self.m_actorType == ActorType.partner) then
			FightManager:AddTotalAnger(self.m_dodgeAddAnger);
		else
			FightManager:AddTotalEnemyAnger(self.m_dodgeAddAnger);
		end
	end
	--触发受到伤害的事件，在扣除伤害之后触发事件，防止更新UI时HP没有及时变化
	EventManager:FireEvent(EventType.GetHurt, self:GetID(), args);
end

--检测当前状态xor添加buff效果(对敌人释放的buff)
function Fighter:checkStateXorAddBuff(attacker, attackerSkill)
	if self:GetFighterState() == FighterState.death then
		return;
	end
	if not attackerSkill:HaveBuffCanReleaseToEnemy() then return end;
	--免疫(被击状态 应 添加一个免疫)
	if self:isSpecialState(FightSpecialStateType.Immune) then return end;

	local deny = false;
	if attackerSkill:HaveBuffCanReleaseToEnemy() then
		__.each(attackerSkill:GetBuff1ID(), function(buff)
			if math.random(1, 100) <= CaculateSkillAccuracyProbability(attacker, self, attackerSkill) * 100 then
				--法术否定（被击状态 应 添加一个否定）
				if not self:isSpecialState(FightSpecialStateType.Deny) then
					if math.random(1, 100) <= buff.pro * 100 then
						self:AddBuff(buff.id, attacker, attackerSkill, false, buff.level);
					end
				else
					deny = true;
				end
			end
		end)
	end
	if deny then -- 法术否定
		__.each(self.m_buffItemList, function(buffClass)
			if buffClass.mSpecialState.m_StateType == FightSpecialStateType.Deny then
				buffClass:Stop();
			end
		end)
	end
end

--检测当前状态xor添加反击伤害
--args = {attackerID = ?; attackState = ?; value = ?; skillType = ?};
function Fighter:checkStateXorAddThornsDamage(attacker, attackerSkill, args)
	if self:GetFighterState() == FighterState.death then
		return;
	end
	if self:isSpecialState(FightSpecialStateType.Thorns) or self:isSpecialState(FightSpecialStateType.HaloThorns) then
		attackerSkill:PlayHitSound();              --播放被击音效
		attacker:AddHitEffect(attackerSkill);      --攻击没有被闪避,添加被击特效

		--这里要修改实际反伤值，不能将args直接传递过去否则显示的伤害值没有*probability
		local thorns_data = clone(args);
		thorns_data.value = math.floor(thorns_data.value * self.m_thornsProbability);

		attacker:DeductHp(thorns_data.value, self);
		EventManager:FireEvent(EventType.GetHurt, attacker:GetID(), thorns_data);
	end
end
--=========================================================================================
--对己方！！！
--
function Fighter:AddAssist(attackerID, attackerSkill, attackClassID)
	if attackerSkill:GetPeriod2() ~= ReleasePeriod.delay then
		return;
	end
	local attacker = ActorManager:GetActor(attackerID);

	-- 施法疲劳器参数获取
	local damageCoefficient, canAddBuff;
	if attackerSkill.m_skillType == SkillType.activeSkill and not attacker:IsEnemy() then
		damageCoefficient, canAddBuff = FightManager.skillCastCheck.getCurSkillCoefficient(attackerID, attackClassID);		
	else
		damageCoefficient, canAddBuff = 1, true;
	end
	if not canAddBuff then
		return;
	end

	if attackerSkill:HaveBuffCanReleaseToAlly() then
		if math.random(1, 100) <= CaculateSkillAccuracyProbability(attacker, self, attackerSkill) * 100 then
			__.each(attackerSkill:GetBuff2ID(), function(buff)
				if math.random(1, 100) <= buff.pro * 100 then
					self:AddBuff(buff.id, attacker, attackerSkill, false, buff.level);
				end
			end)
		end
	end
end

--常驻触发技能 普通的给友方释放buff
function Fighter:checkStateYorAddBuff(friend, skill)
	if self:GetFighterState() == FighterState.death then
		return;
	end
	if not skill:HaveBuffCanReleaseToAlly() then return end;
	--免疫(被击状态 应 添加一个免疫)

	__.each(skill:GetBuff2ID(), function(buff)
		if math.random(1, 100) <= buff.pro * 100 then
			self:AddBuff(buff.id, friend, skill, false, buff.level);
		end
	end)
end
--=========================================================================================

--添加收到的手势技能伤害
function Fighter:AddGestureDamage(value)

	if (self:GetFighterState() == FighterState.death) then
		--如果该角色已经死亡
		return;
	end

	self:DeductHp(value);        --扣除伤害血量

	EventManager:FireEvent(EventType.GetGestureHurt, self:GetID(), value);
end

--添加被击特效
function Fighter:AddHitEffect(attackerSkill)
	local hitEffectName = attackerSkill:GetHitEffectName();

	--[[
	if hitEffectName ~= nil and hitEffectName ~= '' then
		local hitEffect = sceneManager:CreateSceneNode('Armature');
		hitEffect:LoadArmature(hitEffectName);
		hitEffect:SetAnimation('play');
		hitEffect.ZOrder = 100;
		self:AttachEffect(AvatarPos.body, hitEffect);
	end
	--]]
end

--恢复血量
function Fighter:RecoverHP(value)
	if (self:GetFighterState() == FighterState.death) then
		--如果该角色已经死亡
		return;
	end

	self.m_propertyData:RecoverHP(value);

	--触发恢复血量的事件，在扣除伤害之后触发事件，防止更新UI时HP没有及时变化
	EventManager:FireEvent(EventType.RecoverHP, self:GetID(), value);
end
--=========================================================================================
--buff相关
--添加Buff,参数为buff id
function Fighter:AddBuff(buffID, releaser, skill, isForever, buff_level)
	isForever = isForever or false;

	if buffID == nil then
		return;
	end

	local newBuffItem = FightBuffClass.new(buffID, self, releaser, skill, buff_level);

	--判断次数上限
	local index = 1;
	local count = 1;
	while (self.m_buffItemList[index] ~= nil) do
		if buffID == self.m_buffItemList[index]:GetID() then
			if count >= newBuffItem.mMaxCount then
				return;
			end
			count = count + 1;
		end
		index = index + 1;
	end

	index = 1;
	--判断此次添加的buff与角色身上的是否需要替换
	while (self.m_buffItemList[index] ~= nil) do
		--同一buff叠加次数上限
		if (newBuffItem:Reject(self.m_buffItemList[index])) then --排斥
			return ;
		elseif (newBuffItem:Replace(self.m_buffItemList[index])) then --替换
			self.m_buffItemList[index]:Stop();
			table.remove(self.m_buffItemList, index);
		else --共存
			index = index + 1;
		end
	end

	--如果是光环则不可驱散
	if isForever == true then
		newBuffItem.m_lastForever = true;
	end

	--加载光环技能脚本
	local loadHaloScript = function(scriptName)
		if not scriptName or #scriptName == 0 then return end;
		LoadLuaFile('skillScript/' .. scriptName .. '.lua');
		local script = _G[scriptName];
		script:preLoad();
	end

	loadHaloScript(newBuffItem.mCastName);
	loadHaloScript(newBuffItem.mFireName);
	loadHaloScript(newBuffItem.mEndName);

	local cur_animation = self:GetAnimationID()
	newBuffItem:SetID(buffID);
	newBuffItem:Begin();
	table.insert(self.m_buffItemList, newBuffItem);
	self:CheckInterrupt(cur_animation);                            --检查打断
end

--删除身上的所有buff
function Fighter:RemoveAllBuff()
	for _, buffItem in ipairs(self.m_buffItemList) do
		buffItem:Stop();
	end

	self.m_buffItemList = {};
end

--=========================================================================================
--录像相关
--释放技能
function Fighter:RunSkillInRecord(baseTargeter, skillType)
	self:SetFighterState(FighterState.skillAttack);    --设置技能状态

	local targeterList = {};
	targeterList.damageTargeterList = {baseTargeter};

	local skill = self:GetSkill(skillType);
	if (skill ~= nil) and (skillType ~= SkillType.activeSkill) then
		skill:RunSkill(targeterList);
	elseif (skill ~= nil) and (skillType == SkillType.activeSkill) then
		self:ResetAnger();
		self:AddAttackCount();
		self.m_IsShowSkill = false;                --将技能展示标志设置成false

		skill:SetTargeterList(targeterList);
		skill:RunRealSkill();
	end

	if (self.m_actorType == ActorType.hero) or (self.m_actorType == ActorType.partner) then
		FightUIManager:UpdateHeadUI(self:GetTeamIndex(), self:IsEnemy());    --更新人物头像;
	end
end

--录像模式下添加收到的伤害
function Fighter:AddDamageInRecord(damageData)
	if self.m_fighterstate == FighterState.death then
		return;
	end

	local attacker = FightManager:GetFighter(damageData.attackerTeamIndex, damageData.attackerIsEnemy);
	local attackerSkill = attacker:GetSkill(damageData.skillType);

	--添加角色受到的伤害
	if AttackState.miss ~= damageData.state then
		--攻击没有被闪避
		--扣除伤害血量

		if FightType.worldBoss == FightManager:GetFightType() or FightType.unionBoss == FightManager:GetFightType() then
			if self.m_isEnemy then
				if damageData.isLethal then
					--伤害致死
					damageData.damageValue = self.m_propertyData:GetCurrentHP();
				else
					damageData.damageValue = math.floor(damageData.damageValue * WOUBossPanel:GetCurDamageRadioToBoss());
				end
			end
		end

		attackerSkill:PlayHitSound();        --播放被击音效
		self:AddHitEffect(attackerSkill);      --攻击没有被闪避,添加被击特效
		self:DeductHp(damageData.damageValue);    --扣除伤害血量
	else
		--攻击被闪避
	end

	--触发受到伤害的事件，在扣除伤害之后触发事件，防止更新UI时HP没有及时变化
	EventManager:FireEvent(EventType.GetHurt, self:GetID(), {attackerID = attacker:GetID(), attackState = damageData.state, value = damageData.damageValue, skillType = attackerSkill:GetSkillType()});
end

--添加buff伤害
function Fighter:AddBuffDamageInRecord(state, value, isLethal)
	if self.m_fighterstate == FighterState.death then
		return;
	end

	if FightType.worldBoss == FightManager:GetFightType() or FightType.unionBoss == FightManager:GetFightType() then
		if self.m_isEnemy then
			if isLethal then
				--伤害致死
				value = self.m_propertyData:GetCurrentHP();
			else
				value = math.floor(value * WOUBossPanel:GetCurDamageRadioToBoss());
			end
		end
	end

	if state == AttackState.normal then
		self:DeductHp(value);
		EventManager:FireEvent(EventType.BuffDamage, self:GetID(), value, AttackState.normal);
	elseif state == AttackState.RecoverHP then
		self:RecoverHP(value);
	end
end

--录像模式下添加buff
function Fighter:AddBuffInRecord(buffResID, buffID, attacker)
	local newBuffItem = FightBuffClass.new(buffResID, self, attacker, nil);
	newBuffItem:SetID(buffID);
	newBuffItem:Begin();
	table.insert(self.m_buffItemList, newBuffItem);
end

--录像模式下删除buff
function Fighter:RemoveBuffInRecord(buffID, state)
	if state == 1 then
		--正常删除
		local buff, index = self:GetBuff(buffID);
		if buff ~= nil then
			buff:End();
			table.remove(self.m_buffItemList, index);
		end
	else
		--强制删除
		local buff, index = self:GetBuff(buffID);
		if buff ~= nil then
			buff:Stop();
			table.remove(self.m_buffItemList, index);
		end
	end
end

--根据id寻找角色身上的buff
function Fighter:GetBuff(id)
	for index, buff in ipairs(self.m_buffItemList) do
		if buff:GetID() == id then
			return buff, index;
		end
	end

	return nil;
end

--获取角色身上的所有buff
function Fighter:GetBuffItemList()
	return self.m_buffItemList;
end

--========================================================================================

--判断目标是否处于本角色的普通攻击范围内
function Fighter:IsInNormalAttackRange(enemyActor, distance, isSortByRoot)
	--如果没有armature，就直接返回false

	if not self.armature then
		--Debug.report("protected the game from a crash~~")
		print("protected the game from a crash~~")
		return false
	end
	-- 加入3个floor为了调整小数点误差，切勿轻易改动
	local spaceLength = math.floor(math.abs(
	(math.floor(enemyActor:GetPosition().x) - enemyActor:GetDistCompensation()) -
	(math.floor(self:GetPosition().x) - self:GetDistCompensation())));
	if not isSortByRoot then
		spaceLength = math.floor(spaceLength - self:GetWidth() / 2 - enemyActor:GetWidth() / 2);
	end

	enemyActor.spaceLength = spaceLength;        --方便排序

	if (spaceLength <= distance) then
		return true;
	else
		return false;
	end
end


--==========================================================================================
--常驻触发技能触发
function Fighter:castTriggerSkill(triggerType, enemy)
	local add_enemy_ally_buff = function(enemy_list, ally_list, caster, skill)
		if skill:GetBuff1ID() ~= {} then
			for _,target in pairs(enemy_list) do
				target:checkStateXorAddBuff(caster, skill);
			end
		end
		if skill:GetBuff2ID() ~= {} then
			for _,target in pairs(ally_list) do
				target:checkStateYorAddBuff(caster, skill);
			end
		end
	end
	local haveType = function(table_, type_)
		local find = false;
		for _, m_type in pairs(table_) do
			if m_type == type_ then
				find = true;
				break;
			end
		end
		return find;
	end

	for _,skill in pairs(self.m_skillList) do
		if (skill.m_skillClass == SkillClass.triggerSkill) and (haveType(skill.m_comboCause, triggerType)) then
			local targetList = skill:FindSkillTargeters();
			local enemyTarget = targetList and targetList.damageTargeterList or {};
			local allyTarget = targetList and targetList.buffTargeterList or {};
			if haveType(skill.m_comboCause, SkillCause.SkillDamage) then
				add_enemy_ally_buff(enemyTarget, allyTarget, self, skill);
			elseif haveType(skill.m_comboCause, SkillCause.AttackDamamge) then
				add_enemy_ally_buff(enemyTarget, allyTarget, self, skill);
			elseif haveType(skill.m_comboCause, SkillCause.HPDamage) then
				add_enemy_ally_buff(enemyTarget, allyTarget, self, skill);
			elseif haveType(skill.m_comboCause, SkillCause.HPHeal) then
				add_enemy_ally_buff(enemyTarget, allyTarget, self, skill);
			elseif haveType(skill.m_comboCause, SkillCause.KillUnit) then
				add_enemy_ally_buff(enemyTarget, allyTarget, self, skill);
			elseif haveType(skill.m_comboCause, SkillCause.HPTrigger) then
				local beforeHp, afterHp = self.m_propertyData:getBeforeAfterHp();

				if (beforeHp > afterHp) and (beforeHp > skill.m_NumNeed) and (afterHp <= skill.m_NumNeed) then
					add_enemy_ally_buff(enemyTarget, allyTarget, self, skill);
				end
			elseif haveType(skill.m_comboCause, SkillCause.HPResident) then
				local curHp = self.m_propertyData:getCurHp();
				if curHp <= skill.m_NumNeed then
					for _,buff in pairs(skill:GetBuff2ID()) do
						local findBuff = false;
						for _, buffExist in pairs(self.m_buffItemList) do
							if buffExist.mBuffResID == buff.id then
								findBuff = true;
								break;
							end
						end
						if not findBuff then
							if math.random(1, 100) <= buff.pro * 100 then
								self:AddBuff(buff.id, self, skill, false, buff.level);
							end
						end
					end
				elseif curHp > skill.m_NumNeed then
					for _,buff in pairs(skill:GetBuff2ID()) do
						for _, buffExist in pairs(self.m_buffItemList) do
							if buffExist.mBuffResID == buff.id then
								buffExist:Stop();
							end
						end
					end
				end
			end
		end
	end
end

--检测打断当前攻击
function Fighter:CheckInterrupt(pre_animation)
	if self:isSpecialState(FightSpecialStateType.Freeze) or
		self:isSpecialState(FightSpecialStateType.Dizziness) or
		self:isSpecialState(FightSpecialStateType.Chaos) or
		self:isSpecialState(FightSpecialStateType.Silence) then
		if pre_animation == AnimationType.chant then
			if self.m_curSkill then
				local attackList = FightAttackManager.attackList;
				for _, attackClass in pairs(attackList) do
					if attackClass.m_attacker == self then
						effectScriptManager:DestroyEffectScript(attackClass.m_scriptID);
						local attackClass = FightAttackManager:GetAttackClass(attackClass.m_id)
						attackClass:Destroy();
						attackClass.m_attackerSkill:EndSkill();
						EventManager:FireEvent(EventType.Interrupt, self:GetID());
					end
				end
			end
		end
	end
end

function Fighter:SetDebugDie(Arg)
	local arg = UIControlEventArgs(Arg);
	local id = arg.m_pControl.Tag;

	local actor  = ActorManager:GetActor( id )
	if actor then
		actor:SetDie();
	end

end

function Fighter:updateDebug()

	if not debugmode then return end;

	if self.m_fighterstate == FighterState.death then
		return
	end;

	if not self.debug then

		self.debug = uiSystem:CreateControl('TextElement');
		self.debug.Pick = false;
		self.debug:SetFont('huakang_13');

		self.debug.button = uiSystem:CreateControl('Button');
		self.debug.button.Horizontal = ControlLayout.H_RIGHT;
		self.debug.button.Vertical = ControlLayout.V_TOP;

		self.debug.button.Size = Size(20, 20);
		self.debug.button.Font = uiSystem:FindFont('huakang_13');
		self.debug.button.Text = "Die";
		self.debug.button.TextColor = QuadColor(Color.Red);
		self.debug.button.Tag = self:GetID();

		self.debug.button:SubscribeScriptedEvent('Button::ClickEvent', 'Fighter:SetDebugDie');
		self.debug:AddChild(self.debug.button);
		FightManager.desktop:AddChild(self.debug);
	end

	self.debug.Text = self.debuginfo;


	local sceneCamera = FightManager.scene:GetCamera();
	local uiCamera = FightManager.desktop.Camera;
	local uiPosition = SceneToUiPT(sceneCamera, uiCamera, self:GetPosition());

	self.debug.Translate = Vector2(uiPosition.x -35, uiPosition.y + 100 - self:GetHeight() * GlobalData.ActorScaleChange);
	self.debug.button.Translate = Vector2(0, 50);

end

function Fighter:setDebugInfo(str)
	self.debuginfo = str;
	self:updateDebug();
end

function Fighter:DestroyDebugInfo()
	FightManager.desktop:RemoveChild(self.debug);
end

function Fighter:isInScreenCamera()
	local srcUiPos = SceneToUiPT(DamageLabelManager.sceneCamera, DamageLabelManager.uiCamera, Vector3(self:GetPosition().x, self:GetPosition().y, self.m_yPosition));
	if self.m_isEnemy and srcUiPos.x <= FightManager.desktop.Size.Width - self:GetWidth() / 2 then
		return true;
	end
	if not self.m_isEnemy and srcUiPos.x <= FightManager.desktop.Size.Width then
		return true;
	end
	return false;
end
function Fighter:isInScreenWithMargin(margin)
	local srcUiPos = SceneToUiPT(DamageLabelManager.sceneCamera, DamageLabelManager.uiCamera, Vector3(self:GetPosition().x, self:GetPosition().y, self.m_yPosition));
	if self.m_isEnemy and srcUiPos.x <= FightManager.desktop.Size.Width - margin then
		return true;
	end
	if not self.m_isEnemy and srcUiPos.x <= 0 + margin then
		return true;
	end
	return false;
end

--点击测试
function Fighter:Hit( PT )
            --[[
	local pos = self:GetPosition();
	local rect = Rect(Vector2(pos.x - self:GetWidth() * 0.5, pos.y), Size(self:GetWidth(), self:GetHeight()));
	return rect:Contain(PT);
        ]]
        return self:Pick(PT);
end

function Fighter:getName()
	return "hehe"
end

function Fighter:getState()
	if self.m_fighterstate ~= FighterState.death then
		local str = ""
		if  self.m_specialStateFlag[FightSpecialStateType.Freeze]         then  str = str .. "冰" end
		if  self.m_specialStateFlag[FightSpecialStateType.Dizziness]      then  str = str .. "眩" end
		if  self.m_specialStateFlag[FightSpecialStateType.Invincible]     then  str = str .. "无" end
		if  self.m_specialStateFlag[FightSpecialStateType.Thorns]         then  str = str .. "反" end
		if  self.m_specialStateFlag[FightSpecialStateType.Immune]         then  str = str .. "免" end
		if  self.m_specialStateFlag[FightSpecialStateType.Blind]          then  str = str .. "盲" end
		if  self.m_specialStateFlag[FightSpecialStateType.Chaos]          then  str = str .. "乱" end
		if  self.m_specialStateFlag[FightSpecialStateType.Silence]        then  str = str .. "默" end
		if  self.m_specialStateFlag[FightSpecialStateType.Deny]           then  str = str .. "否" end
		if  self.m_specialStateFlag[FightSpecialStateType.Bloodthirsty]   then  str = str .. "嗜" end
		if  self.m_specialStateFlag[FightSpecialStateType.Cleanse]        then  str = str .. "净" end
		if  self.m_specialStateFlag[FightSpecialStateType.Relieve]        then  str = str .. "除" end
		if  self.m_specialStateFlag[FightSpecialStateType.DodgeAddAnger]  then  str = str .. "增" end
		return str;
	else
		return "dead"
	end
end

function Fighter:getSkill()
	if self.m_curSkill then
		return tostring(self.m_curSkill.isCasting) .. "|" .. self.m_curSkill.m_scriptName;
	else
		return "nil"
	end
end

function Fighter:getBuff()
	local buffIndex = 1;
	local str = ""
	while self.m_buffItemList[buffIndex] ~= nil do
		local buffItem = self.m_buffItemList[buffIndex];
		str = str .. tostring(buffItem.mBuffResID) .. ",";
		buffIndex = buffIndex + 1;
	end
	return "[" .. buffIndex-1 .. "]" .. str;
end

function Fighter:getAction()
	local str =  tostring(self.targetInfo);
	return str
end
function Fighter:Pick(PT) --for AddTag 专供战斗中手动选取目标使用

    function square(x) return x * x end;
    local headPoint = self:GetBoneAbsPos("head");
    local rootPoint = self:GetBoneAbsPos("root");

    local dis = math.abs(PT.y - headPoint.y);

    if PT.y < headPoint.y + 10 and PT.y > rootPoint.y and math.abs(PT.x-headPoint.x) < 50 then
        self.pickDis = dis;
        return dis
    else
        return false
    end
end
